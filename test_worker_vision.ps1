# Test Cloudflare Worker Vision Endpoint
$TOKEN = "443e32b61ffceba50a8e415de89fd77b4e30d33dd4b61ad609070df507ce983e"
$BASE_URL = "https://nutritracker-worker.alexandretmoraes110.workers.dev"

Write-Host "=== Testing Cloudflare Worker Vision ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "[1/3] Testing /health endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/health" `
        -Headers @{"X-App-Token"=$TOKEN} `
        -Method GET `
        -TimeoutSec 10
    Write-Host "  ✓ Health: $($response.StatusCode) OK" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Health failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Version Check
Write-Host "[2/3] Testing /version endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/version" `
        -Headers @{"X-App-Token"=$TOKEN} `
        -Method GET `
        -TimeoutSec 10
    $version = ($response.Content | ConvertFrom-Json)
    Write-Host "  ✓ Version: $($version.version)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Version failed: $_" -ForegroundColor Red
}

Write-Host ""

# Test 3: Vision API (with small test image)
Write-Host "[3/3] Testing /vision/analyze_food endpoint..." -ForegroundColor Yellow
Write-Host "  (This may take 20-30 seconds...)" -ForegroundColor Gray

# Small 1x1 pixel PNG base64
$smallImage = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

$body = @{
    image_base64 = $smallImage
} | ConvertTo-Json

try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $response = Invoke-WebRequest -Uri "$BASE_URL/vision/analyze_food" `
        -Headers @{
            "X-App-Token"=$TOKEN
            "Content-Type"="application/json"
        } `
        -Method POST `
        -Body $body `
        -TimeoutSec 60

    $stopwatch.Stop()
    $elapsed = $stopwatch.Elapsed.TotalSeconds

    Write-Host "  ✓ Vision API responded in $([math]::Round($elapsed, 1))s" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green

    $result = $response.Content | ConvertFrom-Json
    if ($result.foods) {
        Write-Host "  Foods detected: $($result.foods.Count)" -ForegroundColor Green
    } else {
        Write-Host "  Response: $($response.Content)" -ForegroundColor Cyan
    }

} catch {
    Write-Host "  ✗ Vision API failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Error details: $($_.ErrorDetails.Message)" -ForegroundColor Red

    if ($_.Exception.Message -match "timeout") {
        Write-Host ""
        Write-Host "⚠️  TIMEOUT DETECTED!" -ForegroundColor Yellow
        Write-Host "   The Worker is taking too long to respond (>60s)" -ForegroundColor Yellow
        Write-Host "   Possible causes:" -ForegroundColor Yellow
        Write-Host "   - OpenAI API is slow or down" -ForegroundColor Yellow
        Write-Host "   - Worker has no OPENAI_API_KEY configured" -ForegroundColor Yellow
        Write-Host "   - Rate limits exceeded" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
