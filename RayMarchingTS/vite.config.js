import { defineConfig } from 'vite'

export default defineConfig(({ mode }) => {

  return {
    plugins: [
      {
        name: 'custom-hmr',
        enforce: 'post',
        // HMR
        handleHotUpdate({ file, server }) {
          if (file.endsWith('.glsl')) {
            console.log('reloading json file...');

            server.ws.send({
              type: 'full-reload',
              path: '*'
            });
          }
        },
      },
    ]
  }
})