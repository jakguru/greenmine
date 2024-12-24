import "dotenv/config";
import knex from "knex";
import { DateTime } from "luxon";
import { readdir } from "node:fs/promises";
import { join } from "node:path";

const remoteDbConfig = {
  client: "mysql2",
  connection: {
    host: process.env.REMOTE_DB_HOST,
    port: Number(process.env.REMOTE_DB_PORT),
    user: process.env.REMOTE_DB_USER,
    password: process.env.REMOTE_DB_PASS,
    database: process.env.REMOTE_DB_NAME,
  },
};

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

const remote = knex(remoteDbConfig);
const local = knex(localDbConfig);

remote.raw("SHOW TABLES").then(async (tables: any) => {
  const tablesNames = tables[0].map(
    (row: any) => row[`Tables_in_${process.env.REMOTE_DB_NAME}`],
  ) as string[];
  const tablesWithDifferences = new Set<string>();
  for (const tableName of tablesNames) {
    try {
      /**
       * First, check that the table structure is the same
       */
      const remoteTableDescription = await remote.raw(`DESCRIBE ${tableName}`);
      const localTableDescription = await local.raw(`DESCRIBE ${tableName}`);

      const remoteColumns = remoteTableDescription[0];
      const localColumns = localTableDescription[0];

      if (JSON.stringify(remoteColumns) !== JSON.stringify(localColumns)) {
        console.warn(`Table structure mismatch for ${tableName}.`);

        // Step 1: Convert descriptions into objects for easier comparison
        const remoteColumnsMap = Object.fromEntries(
          remoteColumns.map((col: any) => [col.Field, col]),
        );
        const localColumnsMap = Object.fromEntries(
          localColumns.map((col: any) => [col.Field, col]),
        );
        let canResume = true;

        // Step 2: Identify missing or differing columns
        console.log(`Differences for table: ${tableName}`);

        // Columns in remote but not in local
        for (const field of Object.keys(remoteColumnsMap)) {
          if (!localColumnsMap[field]) {
            console.log(`- Column ${field} exists in remote but not in local.`);
            canResume = false;
          } else {
            // Compare properties of columns
            const differences = [];
            for (const key of Object.keys(remoteColumnsMap[field])) {
              if (
                remoteColumnsMap[field][key] !== localColumnsMap[field][key]
              ) {
                differences.push(
                  `${key}: remote(${remoteColumnsMap[field][key]}) vs local(${localColumnsMap[field][key]})`,
                );
              }
            }
            if (differences.length) {
              console.log(`- Column ${field} has differences:`);
              console.log(differences.join(", "));
              canResume = false;
            }
          }
        }

        // Columns in local but not in remote
        for (const field of Object.keys(localColumnsMap)) {
          if (!remoteColumnsMap[field]) {
            console.log(`- Column ${field} exists in local but not in remote.`);
            canResume = false;
          }
        }
        if (!canResume) {
          console.warn("Skipping...");
          tablesWithDifferences.add(tableName);
          continue;
        } else {
          console.log("Proceeding...");
        }
      }
      if (
        ["sprints", "issue_sprints", "issue_time_tracking_starts"].includes(
          tableName,
        )
      ) {
        console.warn(`Table "${tableName}" should not be handled normally`);
        tablesWithDifferences.add(tableName);
        continue;
      }
      console.log(`Truncating table "${tableName}"...`);
      try {
        await local(tableName).truncate();
      } catch {
        console.log(
          `Truncate failed for table "${tableName}". Manually delete rows.`,
        );
        await local(tableName).del().where("id", ">", 0);
      }
      console.log(`Re-populating table "${tableName}"...`);
      const allRemoteRows = await remote(tableName).select();
      for (const row of allRemoteRows) {
        await local(tableName).insert(row);
      }
      console.log(`Table "${tableName}" synced successfully.`);
    } catch (error) {
      switch (true) {
        case (error as Error).message.includes("Table") &&
          (error as Error).message.includes("doesn't exist"):
          console.warn(
            `Table "${tableName}" doesn't exist in local database. Skipping...`,
          );
          break;
        default:
          console.error(error);
          break;
      }
    }
  }
  const impactLevels = new Map<string, number>();
  const urgencyLevels = new Map<string, number>();
  const pluginSettings = new Map<string, string>();
  console.log("Loading and parsing plugin settings...");
  const settingsRow = await remote("settings")
    .select("value")
    .where("name", "plugin_nht_redmine")
    .first();
  if (settingsRow) {
    const { value: hashWithIndifferentAccess } = settingsRow;
    if ("string" === typeof hashWithIndifferentAccess) {
      hashWithIndifferentAccess.split("\n").forEach((line) => {
        if (!line || line.startsWith("-") || line.startsWith("!")) {
          return;
        }
        const [key, value] = line.split(": ");
        const fixedValue = value.replace(/('|")/gm, "");
        pluginSettings.set(key, fixedValue);
      });
    }
  }

  console.log("Need to setup enumerations for Impact levels");
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
  for (const row of impactLevelRows) {
    const exists = await local("enumerations").where({
      name: row.name,
      type: row.type,
    });
    if (exists.length === 0) {
      await local("enumerations").insert(row);
    }
    const id = await local("enumerations")
      .where({
        name: row.name,
        type: row.type,
      })
      .select("id")
      .first();
    impactLevels.set(row.name, id.id);
  }
  for (const row of urgencyLevelRows) {
    const exists = await local("enumerations").where({
      name: row.name,
      type: row.type,
    });
    if (exists.length === 0) {
      await local("enumerations").insert(row);
    }
    const id = await local("enumerations")
      .where({
        name: row.name,
        type: row.type,
      })
      .select("id")
      .first();
    urgencyLevels.set(row.name, id.id);
  }
  const defaultImpactLevelName = impactLevelRows.find(
    (row) => row.is_default,
  )!.name;
  const defaultUrgencyLevelName = urgencyLevelRows.find(
    (row) => row.is_default,
  )!.name;
  // @ts-expect-error
  const { "count(*)": impactCount } = await local("enumerations")
    .where({
      type: "IssueImpact",
    })
    .count("*")
    .first();
  // @ts-expect-error
  const { "count(*)": urgencyCount } = await local("enumerations")
    .where({
      type: "IssuePriority",
    })
    .count("*")
    .first();
  const getImpactLevelIdByName = (name: string) => {
    return (
      impactLevels.get(name) || impactLevels.get(defaultImpactLevelName) || 1
    );
  };
  const getUrgencyLevelIdByName = (name: string) => {
    return (
      urgencyLevels.get(name) || urgencyLevels.get(defaultUrgencyLevelName) || 1
    );
  };
  const calculatePriority = async (impact_id: number, urgency_id: number) => {
    const impactEnumeration = await local("enumerations")
      .where({ id: impact_id })
      .first();
    const urgencyEnumeration = await local("enumerations")
      .where({ id: urgency_id })
      .first();

    const impactPosition = impactEnumeration?.position || 0;
    const priorityPosition = urgencyEnumeration?.position || 0;

    const averagePosition =
      (impactPosition / impactCount + priorityPosition / urgencyCount) / 2;

    const calculatedPriority = Math.round(
      Math.max(1, Math.min(10, 10 * (1 - averagePosition))),
    );

    return calculatedPriority;
  };
  console.log(
    `There are ${tablesWithDifferences.size} tables which require a more specific touch.`,
  );
  console.log(Array.from(tablesWithDifferences).join(", "));
  const additionalTables = Array.from(tablesWithDifferences);
  for (const tableName of additionalTables) {
    const rawFromRemote = await remote.select("*").from(tableName);
    let fixed = await Promise.all(
      rawFromRemote.map(async (row) => {
        switch (tableName) {
          case "enumerations":
            return {
              ...row,
              color: null,
            };
          case "issue_statuses":
            return {
              ...row,
              icon: null,
              text_color: null,
              background_color: null,
            };
          case "issues":
            delete row.impact;
            delete row.urgency;
            delete row.monday_dev_item_id;
            return {
              ...row,
              priority_id: getUrgencyLevelIdByName(row.priority),
              impact_id: getImpactLevelIdByName(row.impact),
              calculated_priority: await calculatePriority(
                getImpactLevelIdByName(row.impact),
                getUrgencyLevelIdByName(row.priority),
              ),
            };
          case "journals":
            delete row.monday_dev_update_id;
            return {
              ...row,
            };
          case "projects":
            return {
              ...row,
              avatar: null,
              banner: null,
            };
          case "roles":
            return {
              ...row,
              is_external: false,
            };
          case "sprints":
            return {
              ...row,
              created_at: DateTime.utc().toSQL({ includeOffset: false }),
              updated_at: DateTime.utc().toSQL({ includeOffset: false }),
            };
          case "trackers":
            return {
              ...row,
              icon: null,
              color: null,
              nodes_json: "null",
              edges_json: "null",
              new_issue_statuses_json: "null",
            };
          case "users":
            delete row.monday_api_key;
            return {
              ...row,
              avatar: null,
            };
          default:
            return {
              ...row,
            };
        }
      }),
    );
    switch (tableName) {
      case "issue_sprints":
      case "issue_time_tracking_starts":
        fixed = [];
        break;
    }
    console.log(`Truncating table "${tableName}"...`);
    try {
      await local(tableName).truncate();
    } catch {
      console.log(
        `Truncate failed for table "${tableName}". Manually delete rows.`,
      );
      await local(tableName).del().where("id", ">", 0);
    }
    console.log(`Re-populating table "${tableName}"...`);
    for (const row of fixed) {
      await local(tableName).insert(row);
    }
    console.log(`Table "${tableName}" synced successfully.`);
  }
  console.log("Adding Monday Configuration");
  await local("monday_users").del().where("id", ">", 0);
  await local("monday_boards").del().where("id", ">", 0);
  await local("mondays").del().where("id", ">", 0);
  await local("mondays").insert({
    name: "Imported from NHT Redmine Plugin",
    api_token: process.env.PLUGIN_NHT_REDMINE_MONDAY_ACCESS_TOKEN,
    active: 1,
    created_at: DateTime.utc().toSQL({ includeOffset: false }),
    updated_at: DateTime.utc().toSQL({ includeOffset: false }),
  });
  const { id: mondayInstanceId } = await local("mondays")
    .select("id")
    .where({ api_token: process.env.PLUGIN_NHT_REDMINE_MONDAY_ACCESS_TOKEN })
    .first();
  await local("monday_boards").insert({
    monday_id: mondayInstanceId,
    project_id: Number(process.env.PLUGIN_NHT_REDMINE_MONDAY_BOARD_PROJECT_ID),
    monday_board_id: pluginSettings.get("nht_monday_board_id"),
    board_meta_data: JSON.stringify({}),
    board_field_mapping: JSON.stringify({}),
    created_at: DateTime.utc().toSQL({ includeOffset: false }),
    updated_at: DateTime.utc().toSQL({ includeOffset: false }),
  });
  // Fix the "schema_migrations" table
  console.log("Fixing schema_migrations table...");
  // 1. remove all migrations from the "nht_redmine" plugin
  await local("schema_migrations")
    .where("version", "like", "%nht_redmine%")
    .del();
  await local("schema_migrations")
    .where("version", "like", `%${process.env.LOCAL_DB_PLUGIN_NAME}%`)
    .del();
  // 2. parse the "../src-ruby/db/migrate" directory and insert all migrations
  const localMigrationsPath = join(
    __dirname,
    "..",
    "src-ruby",
    "db",
    "migrate",
  );
  const migrationFiles = await readdir(localMigrationsPath);
  const migrationVersions = migrationFiles.map((f) => {
    const parts = f.split("_") as string[];
    const numeric = parts.shift();
    const batch = parseInt(numeric as string, 10);
    return [batch, process.env.LOCAL_DB_PLUGIN_NAME].join("-");
  });
  await Promise.all(
    migrationVersions.map(async (version) => {
      await local("schema_migrations").where({ version }).del();
      try {
        await local("schema_migrations").insert({ version });
      } catch (error) {
        if ((error as any).code === "ER_DUP_ENTRY") {
          console.warn(`Migration "${version}" already exists in the table.`);
        } else {
          throw error;
        }
      }
    }),
  );
  process.exit(0);
});
