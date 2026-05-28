import { Controller, Get, Inject, ServiceUnavailableException, VERSION_NEUTRAL } from '@nestjs/common';
import { BLOCKCHAIN_PORT, IBlockchainPort } from '../core/ports/blockchain.interface';
import { PrismaService } from '../infrastructure/database/prisma.service';

@Controller({
  version: VERSION_NEUTRAL, // Accessible at the absolute root '/'
})
export class HealthController {
  constructor(
    private prisma: PrismaService,
    @Inject(BLOCKCHAIN_PORT) private blockchain: IBlockchainPort,
  ) { }

  @Get()
  async getHealthStatus() {
    // 1. Check Database connection (Lightweight query)
    const dbCheck = this.prisma.$queryRaw`SELECT 1`
      .then(() => 'UP')
      .catch(() => 'DOWN');

    // 2. Check Toronet network connection
    const blockchainCheck = this.blockchain.checkHealth()
      .then((isHealthy) => (isHealthy ? 'UP' : 'DOWN'))
      .catch(() => 'DOWN');

    const [dbStatus, blockchainStatus] = await Promise.all([dbCheck, blockchainCheck]);

    const isFullyHealthy = dbStatus === 'UP' && blockchainStatus === 'UP';

    const response = {
      status: isFullyHealthy ? 'success' : 'error',
      message: isFullyHealthy
        ? 'ToroPass Issuer Server is live 🚀'
        : 'ToroPass Issuer Server is experiencing degraded performance.',
      timestamp: new Date().toISOString(),
      dependencies: {
        database: dbStatus,
        toronet: blockchainStatus,
      },
    };

    // If a critical service is down, return a 503 instead of a 200 OK
    // This is crucial for AWS/Docker/Kubernetes load balancers to know if they should restart the container
    if (!isFullyHealthy) {
      throw new ServiceUnavailableException(response);
    }

    return response;
  }
}