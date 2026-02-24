import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  const passwordHash = await bcrypt.hash('password123', 12);

  // ─── Users ───────────────────────────────────────────
  const admin = await prisma.user.upsert({
    where: { email: 'admin@taskcontrol.com' },
    update: {},
    create: {
      email: 'admin@taskcontrol.com',
      username: 'admin',
      passwordHash,
      fullName: 'Admin User',
      role: 'ADMIN',
    },
  });

  const john = await prisma.user.upsert({
    where: { email: 'john@taskcontrol.com' },
    update: {},
    create: {
      email: 'john@taskcontrol.com',
      username: 'john',
      passwordHash,
      fullName: 'John Doe',
    },
  });

  const jane = await prisma.user.upsert({
    where: { email: 'jane@taskcontrol.com' },
    update: {},
    create: {
      email: 'jane@taskcontrol.com',
      username: 'jane',
      passwordHash,
      fullName: 'Jane Smith',
    },
  });

  const mike = await prisma.user.upsert({
    where: { email: 'mike@taskcontrol.com' },
    update: {},
    create: {
      email: 'mike@taskcontrol.com',
      username: 'mike',
      passwordHash,
      fullName: 'Mike Johnson',
    },
  });

  const sarah = await prisma.user.upsert({
    where: { email: 'sarah@taskcontrol.com' },
    update: {},
    create: {
      email: 'sarah@taskcontrol.com',
      username: 'sarah',
      passwordHash,
      fullName: 'Sarah Williams',
    },
  });

  const allUsers = [admin, john, jane, mike, sarah];

  // ─── Project 1: E-Commerce Platform ──────────────────
  const ecommerce = await prisma.project.upsert({
    where: { key: 'ECOM' },
    update: { taskCounter: 12 },
    create: {
      key: 'ECOM',
      name: 'E-Commerce Platform',
      description: 'Full-stack e-commerce platform with product catalog, shopping cart, checkout, and order management. Built with React frontend and Node.js backend.',
      ownerId: admin.id,
      visibility: 'PUBLIC',
      taskCounter: 12,
    },
  });

  // Members
  for (const user of allUsers) {
    await prisma.projectMember.upsert({
      where: { projectId_userId: { projectId: ecommerce.id, userId: user.id } },
      update: {},
      create: {
        projectId: ecommerce.id,
        userId: user.id,
        role: user.id === admin.id ? 'ADMIN' : 'MEMBER',
      },
    });
  }

  // Board
  const ecomBoard = await prisma.board.upsert({
    where: { id: 'ecom-board' },
    update: {},
    create: { id: 'ecom-board', projectId: ecommerce.id, name: 'Sprint Board', type: 'KANBAN' },
  });

  // Labels
  const ecomLabels = await Promise.all([
    prisma.label.upsert({ where: { projectId_name: { projectId: ecommerce.id, name: 'Bug' } }, update: {}, create: { projectId: ecommerce.id, name: 'Bug', color: '#E53E3E' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: ecommerce.id, name: 'Feature' } }, update: {}, create: { projectId: ecommerce.id, name: 'Feature', color: '#38A169' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: ecommerce.id, name: 'UI/UX' } }, update: {}, create: { projectId: ecommerce.id, name: 'UI/UX', color: '#805AD5' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: ecommerce.id, name: 'Backend' } }, update: {}, create: { projectId: ecommerce.id, name: 'Backend', color: '#3182CE' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: ecommerce.id, name: 'Performance' } }, update: {}, create: { projectId: ecommerce.id, name: 'Performance', color: '#ED8936' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: ecommerce.id, name: 'Security' } }, update: {}, create: { projectId: ecommerce.id, name: 'Security', color: '#E53E3E' } }),
  ]);

  // Tasks
  const ecomTasks = [
    { key: 'ECOM-1',  title: 'Set up project infrastructure',        description: 'Initialize monorepo, set up CI/CD pipeline, configure Docker containers for local dev and production.', status: 'DONE' as const, priority: 'HIGH' as const, type: 'TASK' as const, assigneeId: admin.id, position: 0 },
    { key: 'ECOM-2',  title: 'Design database schema',               description: 'Create ERD for products, users, orders, reviews, and inventory. Include indexes for search performance.', status: 'DONE' as const, priority: 'HIGH' as const, type: 'TASK' as const, assigneeId: john.id, position: 1 },
    { key: 'ECOM-3',  title: 'Implement user authentication',        description: 'JWT-based auth with OAuth2 (Google, GitHub). Include email verification, password reset, and 2FA.', status: 'DONE' as const, priority: 'CRITICAL' as const, type: 'FEATURE' as const, assigneeId: jane.id, position: 2 },
    { key: 'ECOM-4',  title: 'Build product catalog API',            description: 'REST API for CRUD operations on products. Support filtering, sorting, pagination, and full-text search.', status: 'IN_REVIEW' as const, priority: 'HIGH' as const, type: 'FEATURE' as const, assigneeId: mike.id, position: 0 },
    { key: 'ECOM-5',  title: 'Create shopping cart functionality',   description: 'Persistent cart with add/remove/update quantities. Support guest carts that merge on login.', status: 'IN_REVIEW' as const, priority: 'HIGH' as const, type: 'FEATURE' as const, assigneeId: sarah.id, position: 1 },
    { key: 'ECOM-6',  title: 'Implement checkout flow',              description: 'Multi-step checkout: shipping address, payment method, order review, confirmation. Stripe integration.', status: 'IN_PROGRESS' as const, priority: 'CRITICAL' as const, type: 'FEATURE' as const, assigneeId: john.id, position: 0 },
    { key: 'ECOM-7',  title: 'Fix cart total calculation bug',       description: 'Cart total does not update correctly when applying discount codes. Off-by-one error in tax calculation.', status: 'IN_PROGRESS' as const, priority: 'HIGH' as const, type: 'BUG' as const, assigneeId: jane.id, position: 1 },
    { key: 'ECOM-8',  title: 'Add product image gallery',            description: 'Support multiple images per product with zoom, thumbnails, and lazy loading. Max 10 images, WebP format.', status: 'IN_PROGRESS' as const, priority: 'MEDIUM' as const, type: 'FEATURE' as const, assigneeId: mike.id, position: 2 },
    { key: 'ECOM-9',  title: 'Build order management dashboard',     description: 'Admin dashboard for viewing, filtering, and managing orders. Include status updates and refund processing.', status: 'TO_DO' as const, priority: 'HIGH' as const, type: 'FEATURE' as const, assigneeId: admin.id, position: 0 },
    { key: 'ECOM-10', title: 'Add product reviews and ratings',      description: 'Users can leave star ratings (1-5) and text reviews. Include helpful votes and verified purchase badges.', status: 'TO_DO' as const, priority: 'MEDIUM' as const, type: 'FEATURE' as const, assigneeId: sarah.id, position: 1 },
    { key: 'ECOM-11', title: 'Implement search with Elasticsearch',  description: 'Replace basic SQL search with Elasticsearch for better full-text search, typo tolerance, and faceted filtering.', status: 'TO_DO' as const, priority: 'MEDIUM' as const, type: 'STORY' as const, assigneeId: null, position: 2 },
    { key: 'ECOM-12', title: 'Optimize product listing page speed',  description: 'Page load time exceeds 3s. Implement server-side rendering, image optimization, and database query caching.', status: 'TO_DO' as const, priority: 'LOW' as const, type: 'TASK' as const, assigneeId: null, position: 3 },
  ];

  const createdEcomTasks = [];
  for (const taskData of ecomTasks) {
    const task = await prisma.task.upsert({
      where: { projectId_key: { projectId: ecommerce.id, key: taskData.key } },
      update: {},
      create: {
        projectId: ecommerce.id,
        boardId: ecomBoard.id,
        key: taskData.key,
        title: taskData.title,
        description: taskData.description,
        status: taskData.status,
        priority: taskData.priority,
        type: taskData.type,
        creatorId: admin.id,
        assigneeId: taskData.assigneeId,
        position: taskData.position,
      },
    });
    createdEcomTasks.push(task);
  }

  // Comments on tasks
  const commentData = [
    { taskId: createdEcomTasks[5].id, authorId: john.id, content: 'Stripe integration is mostly done. Need to handle webhook events for payment confirmation and refunds.' },
    { taskId: createdEcomTasks[5].id, authorId: admin.id, content: 'Make sure to test with Stripe test mode cards. Also add proper error handling for declined payments.' },
    { taskId: createdEcomTasks[5].id, authorId: jane.id, content: 'Should we also support PayPal as an alternative? Many users prefer it.' },
    { taskId: createdEcomTasks[6].id, authorId: jane.id, content: 'Found the bug - the discount is applied before tax instead of after. Fixing now.' },
    { taskId: createdEcomTasks[6].id, authorId: admin.id, content: 'Good catch. Please also add unit tests for the edge cases.' },
    { taskId: createdEcomTasks[3].id, authorId: mike.id, content: 'API is ready for review. Added pagination with cursor-based approach for better performance on large catalogs.' },
    { taskId: createdEcomTasks[3].id, authorId: john.id, content: 'Looks good! One suggestion: add rate limiting to prevent abuse of the search endpoint.' },
    { taskId: createdEcomTasks[7].id, authorId: mike.id, content: 'Using react-image-gallery for the zoom feature. WebP conversion is handled server-side with sharp.' },
    { taskId: createdEcomTasks[0].id, authorId: admin.id, content: 'CI/CD pipeline running smoothly on GitHub Actions. Build times average ~4 minutes.' },
    { taskId: createdEcomTasks[4].id, authorId: sarah.id, content: 'Cart merging on login is working. Guest cart items are preserved and merged with any existing cart items.' },
  ];

  for (const comment of commentData) {
    await prisma.comment.create({ data: comment });
  }

  // ─── Project 2: Mobile Fitness App ───────────────────
  const fitness = await prisma.project.upsert({
    where: { key: 'FIT' },
    update: { taskCounter: 8 },
    create: {
      key: 'FIT',
      name: 'Mobile Fitness App',
      description: 'Cross-platform fitness tracking app with workout plans, nutrition logging, progress photos, and social features.',
      ownerId: john.id,
      visibility: 'PUBLIC',
      taskCounter: 8,
    },
  });

  for (const user of [john, jane, mike]) {
    await prisma.projectMember.upsert({
      where: { projectId_userId: { projectId: fitness.id, userId: user.id } },
      update: {},
      create: {
        projectId: fitness.id,
        userId: user.id,
        role: user.id === john.id ? 'ADMIN' : 'MEMBER',
      },
    });
  }

  const fitBoard = await prisma.board.upsert({
    where: { id: 'fit-board' },
    update: {},
    create: { id: 'fit-board', projectId: fitness.id, name: 'Development', type: 'KANBAN' },
  });

  await Promise.all([
    prisma.label.upsert({ where: { projectId_name: { projectId: fitness.id, name: 'iOS' } }, update: {}, create: { projectId: fitness.id, name: 'iOS', color: '#3182CE' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: fitness.id, name: 'Android' } }, update: {}, create: { projectId: fitness.id, name: 'Android', color: '#38A169' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: fitness.id, name: 'API' } }, update: {}, create: { projectId: fitness.id, name: 'API', color: '#805AD5' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: fitness.id, name: 'Design' } }, update: {}, create: { projectId: fitness.id, name: 'Design', color: '#ED8936' } }),
  ]);

  const fitTasks = [
    { key: 'FIT-1', title: 'Design workout tracking UI',             description: 'Create wireframes and high-fidelity mockups for the workout logging screen. Include exercise selection, sets/reps input, and rest timer.', status: 'DONE' as const, priority: 'HIGH' as const, type: 'TASK' as const, assigneeId: jane.id, position: 0 },
    { key: 'FIT-2', title: 'Build exercise database API',            description: 'REST API with 500+ exercises categorized by muscle group, equipment, and difficulty. Include GIF demonstrations.', status: 'DONE' as const, priority: 'HIGH' as const, type: 'FEATURE' as const, assigneeId: john.id, position: 1 },
    { key: 'FIT-3', title: 'Implement workout timer',                description: 'Countdown timer for rest periods between sets. Include notification sound and vibration. Support custom intervals.', status: 'IN_REVIEW' as const, priority: 'MEDIUM' as const, type: 'FEATURE' as const, assigneeId: mike.id, position: 0 },
    { key: 'FIT-4', title: 'Add nutrition logging',                  description: 'Barcode scanner for food items. Integration with USDA food database. Support custom foods and meal templates.', status: 'IN_PROGRESS' as const, priority: 'HIGH' as const, type: 'FEATURE' as const, assigneeId: john.id, position: 0 },
    { key: 'FIT-5', title: 'Fix crash on workout save',              description: 'App crashes when saving workout if any set has empty weight field. Need to handle null/empty values gracefully.', status: 'IN_PROGRESS' as const, priority: 'CRITICAL' as const, type: 'BUG' as const, assigneeId: mike.id, position: 1 },
    { key: 'FIT-6', title: 'Create progress charts',                 description: 'Line charts for weight, body measurements, and lift progression over time. Weekly/monthly/yearly views.', status: 'TO_DO' as const, priority: 'MEDIUM' as const, type: 'FEATURE' as const, assigneeId: jane.id, position: 0 },
    { key: 'FIT-7', title: 'Add social features',                    description: 'Follow friends, share workouts, comment on activities. Include a feed with workout summaries and achievements.', status: 'TO_DO' as const, priority: 'LOW' as const, type: 'STORY' as const, assigneeId: null, position: 1 },
    { key: 'FIT-8', title: 'Implement push notifications',           description: 'Workout reminders, streak notifications, friend activity alerts. Support scheduling and quiet hours.', status: 'TO_DO' as const, priority: 'MEDIUM' as const, type: 'FEATURE' as const, assigneeId: null, position: 2 },
  ];

  for (const taskData of fitTasks) {
    await prisma.task.upsert({
      where: { projectId_key: { projectId: fitness.id, key: taskData.key } },
      update: {},
      create: {
        projectId: fitness.id,
        boardId: fitBoard.id,
        key: taskData.key,
        title: taskData.title,
        description: taskData.description,
        status: taskData.status,
        priority: taskData.priority,
        type: taskData.type,
        creatorId: john.id,
        assigneeId: taskData.assigneeId,
        position: taskData.position,
      },
    });
  }

  // ─── Project 3: DevOps Dashboard ─────────────────────
  const devops = await prisma.project.upsert({
    where: { key: 'DEVOPS' },
    update: { taskCounter: 6 },
    create: {
      key: 'DEVOPS',
      name: 'DevOps Dashboard',
      description: 'Internal monitoring dashboard for CI/CD pipelines, server health, deployment tracking, and incident management.',
      ownerId: sarah.id,
      visibility: 'PRIVATE',
      taskCounter: 6,
    },
  });

  for (const user of [sarah, admin, mike]) {
    await prisma.projectMember.upsert({
      where: { projectId_userId: { projectId: devops.id, userId: user.id } },
      update: {},
      create: {
        projectId: devops.id,
        userId: user.id,
        role: user.id === sarah.id ? 'ADMIN' : 'MEMBER',
      },
    });
  }

  const devopsBoard = await prisma.board.upsert({
    where: { id: 'devops-board' },
    update: {},
    create: { id: 'devops-board', projectId: devops.id, name: 'Kanban Board', type: 'KANBAN' },
  });

  await Promise.all([
    prisma.label.upsert({ where: { projectId_name: { projectId: devops.id, name: 'Infrastructure' } }, update: {}, create: { projectId: devops.id, name: 'Infrastructure', color: '#3182CE' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: devops.id, name: 'Monitoring' } }, update: {}, create: { projectId: devops.id, name: 'Monitoring', color: '#38A169' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: devops.id, name: 'Automation' } }, update: {}, create: { projectId: devops.id, name: 'Automation', color: '#ED8936' } }),
  ]);

  const devopsTasks = [
    { key: 'DEVOPS-1', title: 'Set up Grafana dashboards',           description: 'Create dashboards for CPU, memory, disk usage, and network traffic. Include alerting rules for critical thresholds.', status: 'DONE' as const, priority: 'HIGH' as const, type: 'TASK' as const, assigneeId: sarah.id, position: 0 },
    { key: 'DEVOPS-2', title: 'Implement deployment pipeline view',  description: 'Visual pipeline showing build -> test -> staging -> production stages. Include rollback buttons and deploy history.', status: 'IN_REVIEW' as const, priority: 'HIGH' as const, type: 'FEATURE' as const, assigneeId: admin.id, position: 0 },
    { key: 'DEVOPS-3', title: 'Add incident management',             description: 'Create/track incidents, assign on-call, post-mortem templates. Integration with PagerDuty and Slack.', status: 'IN_PROGRESS' as const, priority: 'CRITICAL' as const, type: 'FEATURE' as const, assigneeId: mike.id, position: 0 },
    { key: 'DEVOPS-4', title: 'Fix false positive alerts',           description: 'Disk usage alerts firing incorrectly due to temp files. Need to exclude /tmp and /var/cache from monitoring.', status: 'IN_PROGRESS' as const, priority: 'HIGH' as const, type: 'BUG' as const, assigneeId: sarah.id, position: 1 },
    { key: 'DEVOPS-5', title: 'Add log aggregation view',            description: 'Centralized log viewer with search, filtering by service/level, and tail mode. Use Loki as backend.', status: 'TO_DO' as const, priority: 'MEDIUM' as const, type: 'FEATURE' as const, assigneeId: null, position: 0 },
    { key: 'DEVOPS-6', title: 'Create cost tracking dashboard',      description: 'Track AWS/GCP cloud costs by service, team, and environment. Include budget alerts and optimization suggestions.', status: 'TO_DO' as const, priority: 'LOW' as const, type: 'STORY' as const, assigneeId: null, position: 1 },
  ];

  for (const taskData of devopsTasks) {
    await prisma.task.upsert({
      where: { projectId_key: { projectId: devops.id, key: taskData.key } },
      update: {},
      create: {
        projectId: devops.id,
        boardId: devopsBoard.id,
        key: taskData.key,
        title: taskData.title,
        description: taskData.description,
        status: taskData.status,
        priority: taskData.priority,
        type: taskData.type,
        creatorId: sarah.id,
        assigneeId: taskData.assigneeId,
        position: taskData.position,
      },
    });
  }

  // ─── Keep the original Demo Project too ──────────────
  const demo = await prisma.project.upsert({
    where: { key: 'DEMO' },
    update: { taskCounter: 4 },
    create: {
      key: 'DEMO',
      name: 'Demo Project',
      description: 'A demo project to get started with TaskControl. Explore the Kanban board, create tasks, and manage your workflow.',
      ownerId: admin.id,
      taskCounter: 4,
    },
  });

  for (const user of [admin, john, jane]) {
    await prisma.projectMember.upsert({
      where: { projectId_userId: { projectId: demo.id, userId: user.id } },
      update: {},
      create: {
        projectId: demo.id,
        userId: user.id,
        role: user.id === admin.id ? 'ADMIN' : 'MEMBER',
      },
    });
  }

  const demoBoard = await prisma.board.upsert({
    where: { id: 'demo-board' },
    update: {},
    create: { id: 'demo-board', projectId: demo.id, name: 'Main Board', type: 'KANBAN' },
  });

  await Promise.all([
    prisma.label.upsert({ where: { projectId_name: { projectId: demo.id, name: 'Bug' } }, update: {}, create: { projectId: demo.id, name: 'Bug', color: '#E53E3E' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: demo.id, name: 'Feature' } }, update: {}, create: { projectId: demo.id, name: 'Feature', color: '#38A169' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: demo.id, name: 'Enhancement' } }, update: {}, create: { projectId: demo.id, name: 'Enhancement', color: '#3182CE' } }),
    prisma.label.upsert({ where: { projectId_name: { projectId: demo.id, name: 'Documentation' } }, update: {}, create: { projectId: demo.id, name: 'Documentation', color: '#805AD5' } }),
  ]);

  const demoTasks = [
    { key: 'DEMO-1', title: 'Set up project infrastructure', status: 'DONE' as const, priority: 'HIGH' as const, type: 'TASK' as const, assigneeId: admin.id, position: 0 },
    { key: 'DEMO-2', title: 'Design database schema',        status: 'IN_REVIEW' as const, priority: 'HIGH' as const, type: 'TASK' as const, assigneeId: john.id, position: 0 },
    { key: 'DEMO-3', title: 'Implement user authentication', status: 'IN_PROGRESS' as const, priority: 'CRITICAL' as const, type: 'FEATURE' as const, assigneeId: jane.id, position: 0 },
    { key: 'DEMO-4', title: 'Create Kanban board UI',        status: 'TO_DO' as const, priority: 'MEDIUM' as const, type: 'FEATURE' as const, assigneeId: null, position: 0 },
  ];

  for (const taskData of demoTasks) {
    await prisma.task.upsert({
      where: { projectId_key: { projectId: demo.id, key: taskData.key } },
      update: {},
      create: {
        projectId: demo.id,
        boardId: demoBoard.id,
        key: taskData.key,
        title: taskData.title,
        status: taskData.status,
        priority: taskData.priority,
        type: taskData.type,
        creatorId: admin.id,
        assigneeId: taskData.assigneeId,
        position: taskData.position,
      },
    });
  }

  console.log('Seed completed successfully!');
  console.log('');
  console.log('Created 5 users:');
  console.log('  admin@taskcontrol.com  (Admin User)   - password123');
  console.log('  john@taskcontrol.com   (John Doe)     - password123');
  console.log('  jane@taskcontrol.com   (Jane Smith)   - password123');
  console.log('  mike@taskcontrol.com   (Mike Johnson) - password123');
  console.log('  sarah@taskcontrol.com  (Sarah Williams) - password123');
  console.log('');
  console.log('Created 4 projects:');
  console.log('  ECOM   - E-Commerce Platform (12 tasks, 10 comments)');
  console.log('  FIT    - Mobile Fitness App (8 tasks)');
  console.log('  DEVOPS - DevOps Dashboard (6 tasks)');
  console.log('  DEMO   - Demo Project (4 tasks)');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
