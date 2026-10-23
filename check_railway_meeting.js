const https = require('https');

const rinaToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NDYsImVtYWlsIjoicmluYUBzdHVkZW50LnRlbGtvbXVuaXZlcnNpdHkuYWMuaWQiLCJyb2xlIjoibWFoYXNpc3dhIiwibmFtYV9sZW5na2FwIjoiUmluYSBLYXJ0aWthIiwiaWF0IjoxNzkzNDIwNzYxLCJleHAiOjE3OTQwMjU1NjF9.kWScLv0QY0_1DvKHby1SKqViozYzhIKrHkZxASMYPM0";

function testMeeting() {
  const payload = JSON.stringify({ lokasi_pertemuan: "Open Library Telkom University" });
  const req = https.request('https://librava-production-d1b8.up.railway.app/api/transactions/69/meeting', {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + rinaToken,
      'Content-Length': Buffer.byteLength(payload)
    }
  }, (res) => {
    let body = '';
    res.on('data', c => body += c);
    res.on('end', () => {
      console.log('HTTP status:', res.statusCode);
      console.log('Body:', body);
    });
  });
  req.on('error', console.error);
  req.write(payload);
  req.end();
}

testMeeting();

