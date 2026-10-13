import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./demo-app/tests/setup.js'],
    include: [
      'demo-app/generated/tests/**/*.test.js',
      'generated/tests/**/*.test.js'
    ]
  }
});
