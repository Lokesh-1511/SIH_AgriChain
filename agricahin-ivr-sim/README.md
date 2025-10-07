# AgriChain IVR Simulator

A lightweight React + Vite project to prototype an agricultural IVR call flow with a split-screen UI.

## Features
- Phone frame + keypad component
- Simple simulated call flow with branching
- Right-hand descriptive/ideas panel
- React Router setup (Home, Simulator)
- Extensible services layer (`services/ivrService.js`)

## Getting Started
```powershell
cd agricahin-ivr-sim
npm install
npm run dev
```
Visit: http://localhost:5175

## Project Structure
```
agricahin-ivr-sim/
  package.json
  vite.config.js
  index.html
  src/
    main.jsx
    App.jsx
    styles.css
    components/
      PhoneFrame.jsx
    pages/
      HomePage.jsx
      SimulatorPage.jsx
    services/
      ivrService.js
```

## Next Ideas
- Persist logs to localStorage
- Add audio prompt playback (Web Audio API)
- Add configurable IVR tree via JSON
- Integrate real crop price API
- Multi-language support

## License
Internal prototype (adapt as needed).
