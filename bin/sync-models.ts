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

/**
 * Sync sprints, projects, issues and the related tables
 */
const doSync = async () => {};

doSync();
