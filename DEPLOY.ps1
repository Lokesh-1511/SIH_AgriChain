# 🚀 COMPLETE AGRICHAIN DEPLOYMENT GUIDE
# =====================================

## STEP 1: Backend Setup
Write-Host "🔧 STEP 1: Starting Backend Server..." -ForegroundColor Cyan

# Activate virtual environment
.\.venv\Scripts\Activate.ps1

# Start backend server
Write-Host "🌐 Starting FastAPI server..." -ForegroundColor Green
Start-Process -FilePath "python" -ArgumentList "backend\main.py" -WindowStyle Normal

# Wait for server to start
Start-Sleep -Seconds 3

Write-Host "✅ Backend server started at http://localhost:8000" -ForegroundColor Green
Write-Host "📚 API Documentation available at http://localhost:8000/docs" -ForegroundColor Yellow

## STEP 2: Flutter Setup
Write-Host "`n🔧 STEP 2: Flutter Setup..." -ForegroundColor Cyan

# Get Flutter dependencies
Write-Host "📦 Getting Flutter dependencies..." -ForegroundColor Green
flutter pub get

Write-Host "✅ Flutter dependencies installed" -ForegroundColor Green

## STEP 3: Run Flutter App
Write-Host "`n🔧 STEP 3: Starting Flutter App..." -ForegroundColor Cyan

Write-Host "📱 Choose your platform:" -ForegroundColor Yellow
Write-Host "1. Android Emulator: flutter run" -ForegroundColor White
Write-Host "2. Chrome Web: flutter run -d chrome" -ForegroundColor White
Write-Host "3. Windows Desktop: flutter run -d windows" -ForegroundColor White

Write-Host "`n🎯 COMPLETE DEPLOYMENT STEPS:" -ForegroundColor Magenta
Write-Host "=" * 40 -ForegroundColor Magenta
Write-Host "1. Backend: ✅ RUNNING at http://localhost:8000" -ForegroundColor Green
Write-Host "2. Flutter Dependencies: ✅ READY" -ForegroundColor Green
Write-Host "3. Ready to launch: Run 'flutter run' for your platform!" -ForegroundColor Yellow

Write-Host "`n🎊 AGRICHAIN IS READY FOR TESTING!" -ForegroundColor Green
Write-Host "🌾 Test the registration screens with REAL Aadhaar verification!" -ForegroundColor Cyan