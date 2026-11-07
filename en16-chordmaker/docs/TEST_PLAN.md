# Test Plan

## Host automated

```bash
cd en16-chordmaker
lua tests/test_chordmaker.lua
lua tests/test_phase1_voice.lua
```

## Hardware checklist

### Basics
- [ ] System Setup pastes with no Debug errors  
- [ ] All 16 elements wired; factory MIDI removed  
- [ ] Store survives reboot of **scripts**  

### Play
- [ ] Enc13 push sustains default chord on MIDI ch1  
- [ ] Enc13 push again releases  
- [ ] Enc0–7 change pitches through octaves while held (no stuck old notes)  
- [ ] Enc0–7 push toggles voices; LED green/dim  
- [ ] Enc8–12 params + resets work  
- [ ] Duplicate pitches (two voices same note) don’t cut early  

### Memory
- [ ] Save/Recall enter via Enc15  
- [ ] Empty slot recall flashes red  
- [ ] Save Arm (Enc14) → amber → save occupied slot only when armed  
- [ ] Enc15 push exits when not armed  
- [ ] Slot 16 save via Arm + Enc15 push  
- [ ] Session bank lost after power cycle (expected until NV verified)  

### Stress
- [ ] Rapid encoder spins remain responsive  
- [ ] Chord switch / recall doesn’t leave stuck notes  
- [ ] USB unplug while held → document host stuck-note behaviour  

### Panic
- [ ] `CM.panic()` clears all notes  
