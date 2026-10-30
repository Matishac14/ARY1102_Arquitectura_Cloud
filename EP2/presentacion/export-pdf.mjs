/**
 * Exporta EP2-FreshBox-Defensa.html → PDF 16:9 (1920×1080) con fondos.
 * Usa Chrome instalado; no altera el HTML de pantalla.
 */
import { chromium } from 'playwright';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const htmlPath = path.join(__dirname, 'EP2-FreshBox-Defensa.html');
const outPath = path.join(__dirname, 'EP2-FreshBox-Defensa.pdf');
const fileUrl = pathToFileURL(htmlPath).href;

const browser = await chromium.launch({ channel: 'chrome', headless: true });
const page = await browser.newPage({
  viewport: { width: 1920, height: 1080 },
  deviceScaleFactor: 1,
});

await page.goto(fileUrl, { waitUntil: 'networkidle', timeout: 120_000 });
await page.emulateMedia({ media: 'print' });
await page.waitForTimeout(800);

await page.pdf({
  path: outPath,
  width: '1920px',
  height: '1080px',
  printBackground: true,
  preferCSSPageSize: true,
  margin: { top: '0', right: '0', bottom: '0', left: '0' },
});

await browser.close();
console.log(`PDF escrito: ${outPath}`);
