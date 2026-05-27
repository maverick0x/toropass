import { Controller, Get, VERSION_NEUTRAL } from '@nestjs/common';

@Controller({
  version: VERSION_NEUTRAL, // This makes it accessible at the absolute root '/'
})
export class HealthController {

  @Get()
  getHealthStatus() {
    return {
      status: 'success',
      message: 'ToroPass Issuer Server is live 🚀',
      timestamp: new Date().toISOString(),
    };
  }
}