export const getJwtSecret = (): string => {
  const secret = process.env.JWT_SECRET?.trim();

  if (!secret || secret.length < 32) {
    throw new Error('JWT_SECRET wajib diatur dan minimal 32 karakter.');
  }

  return secret;
};
