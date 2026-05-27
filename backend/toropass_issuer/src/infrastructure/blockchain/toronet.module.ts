import { Module } from '@nestjs/common';
import { BLOCKCHAIN_PORT } from '../../core/ports/blockchain.interface';
import { ToronetAdapter } from './toronet.adapter';

@Module({
  providers: [
    {
      provide: BLOCKCHAIN_PORT,
      useClass: ToronetAdapter,
    },
  ],
  exports: [BLOCKCHAIN_PORT],
})
export class ToronetModule {}
