export type RefreshTokenPayload = {
  sub: string;
  sessionId: string;
  familyId: string;
  tokenUse: 'refresh';
};
