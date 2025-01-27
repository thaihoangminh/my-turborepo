import { defineConfig } from "tsup";

export default defineConfig((options) => ({
    entry: ["src/button.tsx", "src/card.tsx", "src/code.tsx"],
    format: ["cjs", "esm"],
    dts: true,
    external: ["react"],
    ...options,
}));