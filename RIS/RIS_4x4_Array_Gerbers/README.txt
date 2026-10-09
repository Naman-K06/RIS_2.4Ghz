RIS 4x4 RIS ARRAY — GERBER ARRAY PREPARATION

Source:
- RIS-F_Cu.gbr
- RIS-B_Cu.gbr
- RIS-Edge_Cuts.gbr

Array:
- 4 x 4 = 16 replicated unit cells
- Unit-cell PCB outline: 60 x 60 mm
- RF element pitch: 61.0 mm
- Inter-cell PCB gap: 1.0 mm
- Overall board outline: 243 x 243 mm
- Array spans 3 pitch intervals between the four element positions.

Files:
- RIS-4x4_F_Cu.gbr       Top copper, 16 translated copies
- RIS-4x4_B_Cu.gbr       Bottom copper, 16 translated copies
- RIS-4x4_Edge_Cuts.gbr  Single 243 x 243 mm outer board profile

IMPORTANT:
This is a geometric Gerber replication of the supplied unit-cell copper.
The 16 cells retain the exact original orientation and 61 mm pitch.
The bottom copper therefore remains the same per-cell geometry as the source,
rather than being converted into one continuous common ground plane.

Before fabrication, the array should be checked in a Gerber viewer/KiCad for:
1. Component-to-component clearance,
2. Via/drill locations,
3. Control-line routing to all 16 cells,
4. Solder-mask/paste layers if required,
5. Connector/header strategy,
6. Final board-edge and mounting-hole requirements.

The supplied source did not include a drill file, solder mask, or paste layer,
so those have not been fabricated/generated here.
