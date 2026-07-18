import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import {
  BLOCKCHAIN_PORT,
  IBlockchainPort,
} from '../src/core/ports/blockchain.interface';
import { PrismaService } from '../src/infrastructure/database/prisma.service';
import { HealthController } from '../src/presentation/health.controller';

describe('HealthController (e2e)', () => {
  let app: INestApplication<App>;

  beforeAll(async () => {
    const prisma = {
      $queryRaw: jest.fn().mockResolvedValue([{ '?column?': 1 }]),
    };
    const blockchain: Pick<IBlockchainPort, 'checkHealth'> = {
      checkHealth: jest.fn().mockResolvedValue(true),
    };
    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        { provide: PrismaService, useValue: prisma },
        { provide: BLOCKCHAIN_PORT, useValue: blockchain },
      ],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/ (GET) reports healthy dependencies', async () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect(({ body }) => {
        expect(body.status).toBe('success');
        expect(body.dependencies).toEqual({
          database: 'UP',
          toronet: 'UP',
        });
      });
  });

  afterAll(async () => {
    await app.close();
  });
});
