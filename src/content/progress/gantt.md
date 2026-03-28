gantt
    title DSD-S1-TEST Development Schedule
    dateFormat  YYYY-MM-DD
    axisFormat  %m-%d

    section Phase 1: Infrastructure
    Tech Stack Planning       :done,    task1, 2026-03-25, 2026-03-26
    Static Server & Routing   :done,    task2, 2026-03-27, 2d
    Tech UI Refactoring       :active,  task3, 2026-03-29, 2d
    Markdown Parsing Engine   :         task4, after task3, 3d

    section Phase 2: Features
    CI/CD Pipeline            :         task5, 2026-04-02, 3d
    Testing & Integration     :         task6, after task5, 4d
