gantt
    title DSD-S1-TEST 整体研发进度表
    dateFormat  YYYY-MM-DD
    axisFormat  %m-%d

    section 第一阶段：基础设施
    技术选型规划           :done,    task1, 2026-03-25, 2026-03-26
    静态服务器与基础路由     :done,    task2, 2026-03-27, 2d
    科技风UI重构           :active,  task3, 2026-03-29, 2d
    Markdown解析引擎       :         task4, after task3, 3d

    section 第二阶段：功能扩展
    自动化部署流水线       :         task5, 2026-04-02, 3d
    测试与联调           :         task6, after task5, 4d
