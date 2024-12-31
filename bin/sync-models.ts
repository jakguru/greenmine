import "dotenv/config";
import knex from "knex";

const localDbConfig = {
  client: "mysql2",
  connection: {
    host: process.env.LOCAL_DB_HOST,
    port: Number(process.env.LOCAL_DB_PORT),
    user: process.env.LOCAL_DB_USER,
    password: process.env.LOCAL_DB_PASS,
    database: process.env.LOCAL_DB_NAME,
  },
};

// const remote = knex(remoteDbConfig);
const local = knex(localDbConfig);

/**
 * Sync sprints, projects, issues and the related tables
 */
const impactLevelRows = [
  {
    name: "None",
    position: 1,
    is_default: true,
    type: "IssueImpact",
    active: true,
    project_id: null,
    parent_id: null,
    position_name: null,
    color: null,
  },
  {
    name: "Minor",
    position: 2,
    is_default: false,
    type: "IssueImpact",
    active: true,
    project_id: null,
    parent_id: null,
    position_name: null,
    color: null,
  },
  {
    name: "Moderate",
    position: 3,
    is_default: false,
    type: "IssueImpact",
    active: true,
    project_id: null,
    parent_id: null,
    position_name: null,
    color: null,
  },
  {
    name: "Significant",
    position: 3,
    is_default: false,
    type: "IssueImpact",
    active: true,
    project_id: null,
    parent_id: null,
    position_name: null,
    color: null,
  },
  {
    name: "Extensive",
    position: 4,
    is_default: false,
    type: "IssueImpact",
    active: true,
    project_id: null,
    parent_id: null,
    position_name: null,
    color: null,
  },
];
const urgencyLevelRows = [
  {
    name: "None",
    position: 1,
    is_default: true,
    type: "IssuePriority",
    active: true,
    project_id: null,
    parent_id: null,
    position_name: null,
    color: null,
  },
  {
    name: "Low",
    position: 2,
    is_default: false,
    type: "IssuePriority",
    active: true,
    project_id: null,
    parent_id: null,
    position_name: null,
    color: null,
  },
  {
    name: "Medium",
    position: 3,
    is_default: false,
    type: "IssuePriority",
    active: true,
    project_id: null,
    parent_id: null,
    position_name: null,
    color: null,
  },
  {
    name: "High",
    position: 4,
    is_default: false,
    type: "IssuePriority",
    active: true,
    project_id: null,
    parent_id: null,
    position_name: null,
    color: null,
  },
  {
    name: "Critical",
    position: 5,
    is_default: false,
    type: "IssuePriority",
    active: true,
    project_id: null,
    parent_id: null,
    position_name: null,
    color: null,
  },
  {
    name: "Immediate",
    position: 6,
    is_default: false,
    type: "IssuePriority",
    active: true,
    project_id: null,
    parent_id: null,
    position_name: null,
    color: null,
  },
];
const doSync = async () => {
  for (const row of impactLevelRows) {
    const exists = await local("enumerations").where({
      name: row.name,
      type: row.type,
    });
    if (exists.length === 0) {
      await local("enumerations").insert(row);
      console.log(`Inserted ${row.name}`);
    } else {
      console.log(`Skipped ${row.name}`);
    }
  }
  for (const row of urgencyLevelRows) {
    const exists = await local("enumerations").where({
      name: row.name,
      type: row.type,
    });
    if (exists.length === 0) {
      await local("enumerations").insert(row);
      console.log(`Inserted ${row.name}`);
    } else {
      console.log(`Skipped ${row.name}`);
    }
  }
  process.exit(0);
};

doSync();
