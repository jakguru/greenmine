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

const local = knex(localDbConfig);

local.raw("SHOW TABLES").then(async (tables: any) => {
  const tablesNames = tables[0].map(
    (row: any) => row[`Tables_in_${process.env.REMOTE_DB_NAME}`],
  ) as string[];
  await local.raw("SET FOREIGN_KEY_CHECKS = 0");
  for (const tableName of tablesNames) {
    await local.raw(`DROP TABLE ${tableName}`);
  }
  await local.raw("SET FOREIGN_KEY_CHECKS = 1");
  process.exit(0);
});
