<template>
  <v-container fluid class="page-projects-show">
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{ $t(`pages.${String($route.name)}.title`) }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
      <v-divider />
      <v-sheet v-bind="projectHeroBindings">
        <div class="top">
          <v-avatar size="150" :color="accentColor" class="elevation-5">
            <v-img :src="avatarSource" />
          </v-avatar>
        </div>
        <div class="bottom">
          <h1 class="display-1 font-weight-bold mb-3">
            {{ model.name }}
          </h1>
        </div>
      </v-sheet>
      <v-divider />
      <v-toolbar color="transparent">
        <v-slide-group show-arrows class="mx-2">
          <v-slide-group-item v-for="mi in menu" :key="mi.key">
            <template v-if="Array.isArray(mi.children)">
              <v-btn-group
                divided
                :base-color="accentColor"
                density="compact"
                class="mx-1 my-2"
                style="height: 24px; position: relative; top: 1.5px"
              >
                <v-menu>
                  <template #activator="{ props }">
                    <v-btn v-bind="props" size="x-small">
                      <span>{{ mi.title }}</span>
                    </v-btn>
                  </template>
                  <v-card color="surface">
                    <v-list-item
                      v-for="cmi in mi.children"
                      :key="`${mi.key}-${cmi.key}`"
                      :title="cmi.title"
                      :to="cmi.to"
                    />
                  </v-card>
                </v-menu>
                <v-menu>
                  <template #activator="{ props }">
                    <v-btn v-bind="props" icon="mdi-menu-down" size="x-small" />
                  </template>
                  <v-card color="surface">
                    <v-list-item
                      v-for="cmi in mi.children"
                      :key="`${mi.key}-${cmi.key}`"
                      :title="cmi.title"
                      :to="cmi.to"
                    />
                  </v-card>
                </v-menu>
              </v-btn-group>
            </template>
            <template v-else>
              <v-btn
                variant="elevated"
                :color="accentColor"
                size="x-small"
                class="mx-1 my-2"
                height="24px"
                style="position: relative; top: 1px"
                :to="mi.to"
                :exact="true"
              >
                <span>{{ mi.title }}</span>
              </v-btn>
            </template>
          </v-slide-group-item>
        </v-slide-group>
      </v-toolbar>
      <v-divider />
      <v-toolbar v-if="'projects-id' === $route.name" color="transparent">
        <v-slide-group show-arrows class="mx-2">
          <v-slide-group-item>
            <v-chip
              :color="publicStatusChip.color"
              variant="elevated"
              size="small"
              class="mx-1"
            >
              <v-icon class="me-2">{{ publicStatusChip.icon }}</v-icon>
              <strong>{{ publicStatusChip.text }}</strong>
            </v-chip>
          </v-slide-group-item>
          <v-slide-group-item>
            <v-chip
              :color="status.color"
              variant="elevated"
              size="small"
              class="mx-1"
            >
              <v-icon class="me-2">{{ status.icon }}</v-icon>
              <strong>{{ status.label }}</strong>
            </v-chip>
          </v-slide-group-item>
          <v-slide-group-item v-if="model.homepage">
            <v-chip
              :color="accentColor"
              variant="elevated"
              size="small"
              class="mx-1"
              :href="model.homepage"
              target="_blank"
            >
              <v-icon class="me-2">mdi-home</v-icon>
              <strong>{{ prettifiedHomepage }}</strong>
            </v-chip>
          </v-slide-group-item>
        </v-slide-group>
      </v-toolbar>
      <v-divider v-if="'projects-id' === $route.name" />
      <template v-if="'projects-id' === $route.name">
        <v-container fluid class="pa-0">
          <v-row no-gutters class="with-dividing-border">
            <v-col cols="12" sm="12" md="6" xl="8" order-md="2">
              <v-container>
                <v-row v-if="model.description">
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label rounded-lg">
                        <small>{{
                          $t(`pages.projects-id.content.description`)
                        }}</small>
                      </v-label>
                      <v-card-text class="bg-background">
                        <RenderMarkdown
                          v-if="model.description"
                          :raw="model.description"
                        />
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row v-if="currentUserCan('get_chart_for_activity_summary')">
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.activitySummary`)
                        }}</small>
                      </v-label>
                      <ActivitySummaryChart
                        :form-authenticity-token="formAuthenticityToken"
                        :endpoint="`/projects/${model.identifier}/charts/activity-summary`"
                        :min-date-time="minDateTime"
                      />
                    </v-card>
                  </v-col>
                </v-row>
                <v-row
                  v-if="
                    hasModule('issue_tracking') &&
                    currentUserCan('view_issues') &&
                    currentUserCan('get_chart_for_issues_by_tracker')
                  "
                >
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.issueSummaryByTracker`)
                        }}</small>
                      </v-label>
                      <IssuesByTrackerChart
                        :form-authenticity-token="formAuthenticityToken"
                        :endpoint="`/projects/${model.identifier}/charts/issues-summary-by-tracker`"
                        :min-date-time="minDateTime"
                      />
                    </v-card>
                  </v-col>
                </v-row>
                <v-row
                  v-if="
                    hasModule('issue_tracking') &&
                    currentUserCan('view_issues') &&
                    currentUserCan('get_chart_for_issues_by_status')
                  "
                >
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.issueSummaryByStatus`)
                        }}</small>
                      </v-label>
                      <IssuesByStatusChart
                        :form-authenticity-token="formAuthenticityToken"
                        :endpoint="`/projects/${model.identifier}/charts/issues-summary-by-status`"
                        :min-date-time="minDateTime"
                      />
                    </v-card>
                  </v-col>
                </v-row>
                <v-row
                  v-if="
                    hasModule('time_tracking') &&
                    currentUserCan('view_time_entries') &&
                    currentUserCan('get_chart_for_time_summary')
                  "
                >
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.timeSummaryChart`)
                        }}</small>
                      </v-label>
                      <TimeUtilizationSummaryChart
                        :form-authenticity-token="formAuthenticityToken"
                        :endpoint="`/projects/${model.identifier}/charts/time-summary`"
                        :min-date-time="minDateTime"
                      />
                    </v-card>
                  </v-col>
                </v-row>
              </v-container>
            </v-col>
            <v-col cols="12" sm="6" md="3" xl="2" order-md="1">
              <v-container>
                <v-row>
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.members`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent">
                        <template
                          v-for="mr in membershipsToShow"
                          :key="`memberships-role-${mr.role.id}`"
                        >
                          <v-list-subheader>
                            <strong>{{ mr.role.name }}</strong>
                          </v-list-subheader>
                          <v-slide-group show-arrows class="mx-2">
                            <v-slide-group-item
                              v-for="p in mr.principals"
                              :key="`memberships-role-${mr.role.id}-principal-${p.id}`"
                            >
                              <div class="py-2 px-1">
                                <v-menu open-on-hover :offset="[0, -20]">
                                  <template #activator="{ props }">
                                    <v-badge
                                      location="bottom end"
                                      :offset-x="5"
                                      :offset-y="5"
                                      :icon="
                                        ['group', 'group_anonymous'].includes(
                                          p.type,
                                        )
                                          ? 'mdi-account-group'
                                          : 'mdi-account'
                                      "
                                      :color="
                                        ['group', 'group_anonymous'].includes(
                                          p.type,
                                        )
                                          ? 'primary'
                                          : 'secondary'
                                      "
                                    >
                                      <v-btn
                                        icon
                                        v-bind="props"
                                        :color="accentColor"
                                        size="small"
                                      >
                                        <v-avatar :color="accentColor">
                                          <v-img
                                            :src="avatarUrlForPrincipal(p)"
                                          />
                                        </v-avatar>
                                      </v-btn>
                                    </v-badge>
                                  </template>
                                  <v-card
                                    :color="surfaceColor"
                                    width="275"
                                    min-height="50"
                                  >
                                    <v-sheet
                                      color="transparent"
                                      class="d-flex w-100 justify-center align-center"
                                      height="150"
                                    >
                                      <v-avatar :color="accentColor" size="100">
                                        <v-img
                                          :src="avatarUrlForPrincipal(p)"
                                        />
                                      </v-avatar>
                                    </v-sheet>
                                    <v-list-item :title="p.name">
                                      <template
                                        v-if="'user' === p.type"
                                        #append
                                      >
                                        <v-btn
                                          variant="elevated"
                                          :color="accentColor"
                                          size="x-small"
                                          height="24px"
                                          :to="{
                                            name: 'users-id',
                                            params: { id: p.id },
                                          }"
                                          :exact="true"
                                        >
                                          <span>{{
                                            $t(
                                              "pages.projects-id.content.viewProfile",
                                            )
                                          }}</span>
                                        </v-btn>
                                      </template>
                                    </v-list-item>
                                  </v-card>
                                </v-menu>
                              </div>
                            </v-slide-group-item>
                          </v-slide-group>
                        </template>
                      </v-list>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row
                  v-if="subprojects.length || currentUserCan('add_subprojects')"
                >
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.subprojects`)
                        }}</small>
                      </v-label>
                      <v-list
                        v-if="subprojects.length"
                        class="bg-transparent pb-0"
                      >
                        <v-list-item
                          v-for="sp in subprojects"
                          :key="`subproject-${sp.identifier}`"
                          :title="sp.name"
                          :subtitle="sp.identifier || ''"
                          two-line
                          :to="{
                            name: 'projects-id',
                            params: { id: sp.identifier },
                          }"
                        >
                          <template #prepend>
                            <v-avatar
                              size="24"
                              :image="sp.avatar || defaultProjectAvatar"
                              :color="accentColor"
                            />
                          </template>
                        </v-list-item>
                      </v-list>
                      <v-divider
                        v-if="
                          subprojects.length &&
                          currentUserCan('add_subprojects')
                        "
                      />
                      <v-card-actions v-if="currentUserCan('add_subprojects')">
                        <v-spacer />
                        <v-btn
                          variant="elevated"
                          :color="accentColor"
                          size="x-small"
                          height="24px"
                          :to="{
                            name: 'projects-new',
                            query: { parent_id: model.id },
                          }"
                          :exact="true"
                        >
                          <span>{{ $t("pages.projects-id.content.new") }}</span>
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row v-if="gitlabProjects.length">
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.gitlabProjects`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent pb-0">
                        <v-list-item
                          v-for="glp in gitlabProjects"
                          :key="`gitlabProject-${glp.id}`"
                          :title="glp.name_with_namespace"
                          :subtitle="glp.path_with_namespace"
                          two-line
                          :href="glp.web_url"
                          target="_blank"
                        >
                          <template #append>
                            <v-avatar size="24" :image="iconGitlab" />
                          </template>
                        </v-list-item>
                      </v-list>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row
                  v-if="
                    mondayBoard &&
                    currentUserCan('view_associated_monday_board')
                  "
                >
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.mondayBoard`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent pb-0">
                        <v-list-item
                          :title="mondayBoard?.board_meta_data?.name"
                          two-line
                          :href="mondayBoard?.board_meta_data?.url"
                          target="_blank"
                        >
                          <template #append>
                            <img height="24" :src="iconMonday" />
                          </template>
                        </v-list-item>
                      </v-list>
                    </v-card>
                  </v-col>
                </v-row>
              </v-container>
            </v-col>
            <v-col cols="12" sm="6" md="3" xl="2" order-md="3">
              <v-container>
                <v-row
                  v-if="
                    hasModule('time_tracking') &&
                    currentUserCan('view_time_entries')
                  "
                >
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.timeSummary`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent pb-0">
                        <v-list-item
                          v-if="
                            'number' === typeof totalEstimatedHours &&
                            totalEstimatedHours > 0
                          "
                          :title="
                            $t(
                              'pages.projects-id.content.timeSummaryPart.estimated',
                            )
                          "
                        >
                          <template #append>
                            <v-chip label color="info" size="small">
                              {{ formatDuration(totalEstimatedHours) }}
                            </v-chip>
                          </template>
                        </v-list-item>
                        <v-list-item
                          v-if="'number' === typeof totalHours"
                          :title="
                            $t(
                              'pages.projects-id.content.timeSummaryPart.spent',
                            )
                          "
                        >
                          <template #append>
                            <v-chip label color="info" size="small">
                              {{ formatDuration(totalHours) }}
                            </v-chip>
                          </template>
                        </v-list-item>
                      </v-list>
                      <v-divider />
                      <v-card-actions>
                        <v-spacer />
                        <v-btn
                          variant="elevated"
                          :color="accentColor"
                          size="x-small"
                          height="24px"
                          :to="{
                            name: 'projects-project-id-time-entries-new',
                            params: { project_id: model.identifier },
                          }"
                          :exact="true"
                        >
                          <span>{{
                            $t("pages.projects-id.content.logTime")
                          }}</span>
                        </v-btn>
                        <v-btn
                          variant="elevated"
                          :color="accentColor"
                          size="x-small"
                          height="24px"
                          :to="{
                            name: 'projects-project-id-time-entries',
                            params: { project_id: model.identifier },
                          }"
                          :exact="true"
                        >
                          <span>{{
                            $t("pages.projects-id.content.details")
                          }}</span>
                        </v-btn>
                        <v-btn
                          variant="elevated"
                          :color="accentColor"
                          size="x-small"
                          height="24px"
                          :to="{
                            name: 'projects-project-id-time-entries-report',
                            params: { project_id: model.identifier },
                          }"
                          :exact="true"
                        >
                          <span>{{
                            $t("pages.projects-id.content.report")
                          }}</span>
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row v-if="hasModule('news') && news.length">
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.news`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent">
                        <NewsPreview
                          v-for="n in news"
                          :key="n.id"
                          :news="n"
                          in-project
                        />
                      </v-list>
                      <v-divider />
                      <v-card-actions>
                        <v-spacer />
                        <v-btn
                          variant="elevated"
                          :color="accentColor"
                          size="x-small"
                          height="24px"
                          :to="{
                            name: 'projects-project-id-news',
                            params: { project_id: model.identifier },
                          }"
                          :exact="true"
                        >
                          <span>{{
                            $t("pages.projects-id.content.allNews")
                          }}</span>
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row v-if="hasModule('wiki') && topLevelWikiPages.length">
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.wikiPages`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent pb-0">
                        <v-list-item
                          v-for="wp in topLevelWikiPages"
                          :key="`wiki-page-${wp.id}`"
                          :title="wp.title"
                          :to="wp.url"
                        />
                      </v-list>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row
                  v-if="
                    hasModule('documents') &&
                    documents.length &&
                    currentUserCan('view_documents')
                  "
                >
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.documents`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent pb-0">
                        <template
                          v-for="(docs, cat) in documentsByCategory"
                          :key="`doc-cat-${cat}`"
                        >
                          <v-list-subheader>{{ cat }}</v-list-subheader>
                          <v-list-item
                            v-for="f in docs"
                            :key="`file-${f.id}`"
                            :title="f.title"
                            :subtitle="f.description"
                          >
                            <template #append>
                              <v-btn
                                :icon="true"
                                variant="elevated"
                                :color="accentColor"
                                size="24px"
                                :to="{
                                  name: 'documents-id',
                                  params: { id: f.id },
                                }"
                                :exact="true"
                                class="me-2"
                              >
                                <v-icon size="13">mdi-file-find</v-icon>
                              </v-btn>
                              <v-btn
                                :icon="true"
                                variant="elevated"
                                :color="accentColor"
                                size="24px"
                                :href="`/attachments/download/${f.attachment.id}/${f.attachment.filename}`"
                                target="_blank"
                              >
                                <v-icon size="13">mdi-download</v-icon>
                              </v-btn>
                            </template>
                          </v-list-item>
                        </template>
                      </v-list>
                      <v-divider v-if="currentUserCan('add_documents')" />
                      <v-card-actions v-if="currentUserCan('add_documents')">
                        <v-spacer />
                        <v-btn
                          variant="elevated"
                          :color="accentColor"
                          size="x-small"
                          height="24px"
                          class="me-2"
                          :to="{
                            name: 'projects-project-id-files-new',
                            params: { project_id: model.identifier },
                          }"
                          :exact="true"
                        >
                          <span>{{ $t("pages.projects-id.content.new") }}</span>
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-col>
                </v-row>
                <v-row
                  v-if="
                    hasModule('files') &&
                    currentUserCan('view_files') &&
                    files.length
                  "
                >
                  <v-col cols="12">
                    <v-card
                      variant="outlined"
                      class="overflow-y-visible"
                      elevation="3"
                    >
                      <v-label class="mx-2 project-card-label">
                        <small>{{
                          $t(`pages.projects-id.content.files`)
                        }}</small>
                      </v-label>
                      <v-list class="bg-transparent pb-0">
                        <v-list-item
                          v-for="f in [...files].slice(0, 5)"
                          :key="`file-${f.id}`"
                          :title="f.filename"
                          :subtitle="f.digest"
                        >
                          <template #append>
                            <v-btn
                              :icon="true"
                              variant="elevated"
                              :color="accentColor"
                              size="24px"
                              :to="{
                                name: 'attachments-id',
                                params: { id: f.id },
                              }"
                              :exact="true"
                              class="me-2"
                            >
                              <v-icon size="13">mdi-file-find</v-icon>
                            </v-btn>
                            <v-btn
                              :icon="true"
                              variant="elevated"
                              :color="accentColor"
                              size="24px"
                              :href="`/attachments/download/${f.id}`"
                              target="_blank"
                            >
                              <v-icon size="13">mdi-download</v-icon>
                            </v-btn>
                          </template>
                        </v-list-item>
                      </v-list>
                      <v-divider />
                      <v-card-actions>
                        <v-spacer />
                        <v-btn
                          v-if="currentUserCan('manage_files')"
                          variant="elevated"
                          :color="accentColor"
                          size="x-small"
                          height="24px"
                          class="me-2"
                          :to="{
                            name: 'projects-project-id-files-new',
                            params: { project_id: model.identifier },
                          }"
                          :exact="true"
                        >
                          <span>{{ $t("pages.projects-id.content.new") }}</span>
                        </v-btn>
                        <v-btn
                          variant="elevated"
                          :color="accentColor"
                          size="x-small"
                          height="24px"
                          :to="{
                            name: 'projects-project-id-files',
                            params: { project_id: model.identifier },
                          }"
                          :exact="true"
                        >
                          <span>{{
                            $t("pages.projects-id.content.allFiles")
                          }}</span>
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-col>
                </v-row>
              </v-container>
            </v-col>
          </v-row>
        </v-container>
      </template>
      <template
        v-else-if="
          isCurrentRoute(['projects-id-settings', 'projects-id-settings-tab'])
        "
      >
        <ProjectsShowSettingsPartial v-bind="propsForPartial" />
      </template>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useI18n } from "vue-i18n";
import { useRoute } from "vue-router";
import { useSystemSurfaceColor, useSystemAccentColor } from "@/utils/app";
import { formatDuration } from "@/utils/formatting";
import iconGitlab from "@/assets/images/icon-gitlab.svg?url";
import iconMonday from "@/assets/images/icon-monday.svg?url";
import defaultProjectAvatar from "@/assets/images/default-project-avatar.svg?url";
import defaultProjectBanner from "@/assets/images/default-project-banner.jpg?url";
import { RenderMarkdown } from "@/components/rendering";
import { NewsPreview } from "@/components/news";
import {
  ActivitySummaryChart,
  IssuesByTrackerChart,
  IssuesByStatusChart,
  TimeUtilizationSummaryChart,
} from "@/components/charts";
import ProjectsShowSettingsPartial from "@/partials/projects/show/settings.vue";

import type { PropType } from "vue";
import type {
  ProjectModel,
  ProjectMember,
  ProjectIssueCategory,
  ProjectVersion,
  ProjectRepository,
  ProjectCustomField,
  ProjectValuesProp,
  ProjectPermissions,
  Principal,
  News,
  Tracker,
  GitlabProject,
  FridayMenuItem,
  ProjectWikiPageLink,
  PrincipalRole,
  ProjectDocumentLink,
  File,
  MondayBoard,
} from "@/friday";

export default defineComponent({
  name: "ProjectsShow",
  components: {
    RenderMarkdown,
    NewsPreview,
    ActivitySummaryChart,
    IssuesByTrackerChart,
    IssuesByStatusChart,
    TimeUtilizationSummaryChart,
    ProjectsShowSettingsPartial,
  },
  props: {
    formAuthenticityToken: {
      type: String,
      required: true,
    },
    id: {
      type: [String, Number] as PropType<string | number | null | undefined>,
      default: null,
    },
    model: {
      type: Object as PropType<ProjectModel>,
      required: true,
    },
    members: {
      type: Array as PropType<ProjectMember[]>,
      required: true,
    },
    menu: {
      type: Array as PropType<FridayMenuItem[]>,
      required: true,
    },
    issueCategories: {
      type: Array as PropType<ProjectIssueCategory[]>,
      required: true,
    },
    versions: {
      type: Array as PropType<ProjectVersion[]>,
      required: true,
    },
    repositories: {
      type: Array as PropType<ProjectRepository[]>,
      required: true,
    },
    customFields: {
      type: Array as PropType<ProjectCustomField[]>,
      required: true,
    },
    values: {
      type: Object as PropType<ProjectValuesProp>,
      required: true,
    },
    permissions: {
      type: Object as PropType<ProjectPermissions>,
      required: true,
    },
    principalsByRole: {
      type: Array as PropType<
        Array<{
          role: PrincipalRole;
          principals: Principal[];
        }>
      >,
      required: true,
    },
    subprojects: {
      type: Array as PropType<ProjectModel[]>,
      required: true,
    },
    news: {
      type: Array as PropType<News[]>,
      required: true,
    },
    trackers: {
      type: Array as PropType<Tracker[]>,
      required: true,
    },
    openIssuesByTracker: {
      type: Object as PropType<Record<string, number>>,
      required: true,
    },
    totalIssuesByTracker: {
      type: Object as PropType<Record<string, number>>,
      required: true,
    },
    totalHours: {
      type: [String, Number] as PropType<string | number | null>,
      required: true,
    },
    totalEstimatedHours: {
      type: [String, Number] as PropType<string | number | null>,
      required: true,
    },
    gitlabProjects: {
      type: Array as PropType<GitlabProject[]>,
      required: true,
    },
    parents: {
      type: Array as PropType<ProjectModel[]>,
      required: true,
    },
    wiki: {
      type: Array as PropType<ProjectWikiPageLink[]>,
      required: true,
    },
    documents: {
      type: Array as PropType<ProjectDocumentLink[]>,
      required: true,
    },
    files: {
      type: Array as PropType<File[]>,
      required: true,
    },
    mondayBoard: {
      type: Object as PropType<MondayBoard | null>,
      required: true,
    },
  },
  setup(props) {
    // const toast = inject<ToastService>("toast");
    // const ls = inject<LocalStorageService>("ls");
    // const api = inject<ApiService>("api");
    const route = useRoute();
    // const router = useRouter();
    // const reloadRouteDataAction = useReloadRouteData(route, api, toast);
    // const reloadAppDataAction = useReloadAppData(ls, api);
    const surfaceColor = useSystemSurfaceColor();
    const accentColor = useSystemAccentColor();
    const model = computed(() => props.model);
    const values = computed(() => props.values);
    const parents = computed(() => props.parents);
    const permissions = computed(() => props.permissions);
    const enabledModuleNames = computed(() => model.value.enabled_module_names);
    const statuses = computed(() => values.value.statuses);
    const { t } = useI18n({ useScope: "global" });
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.projects.title"), to: { name: "projects" } },
        ...parents.value.map((model) => ({
          title: model.name,
          to: { name: "projects-id", params: { id: model.identifier } },
        })),
        { title: model.value.name },
      ],
    }));
    const bannerSource = computed(() => {
      return model.value.banner || defaultProjectBanner;
    });
    const avatarSource = computed(() => {
      return model.value.avatar || defaultProjectAvatar;
    });
    const projectHeroBindings = computed(() => ({
      class: ["project-hero"],
      height: 300,
      style: {
        "--project-hero-background": `url(${bannerSource.value})`,
      },
    }));
    const publicStatusChip = computed(() => ({
      icon: model.value.is_public ? "mdi-earth" : "mdi-earth-off",
      color: model.value.is_public ? "info" : "success",
      text: model.value.is_public ? t("labels.public") : t("labels.private"),
    }));
    const status = computed(() => {
      return statuses.value.find(
        (status) => status.value === model.value.status,
      )!;
    });
    const prettifiedHomepage = computed(() => {
      if (!model.value.homepage) return null;
      const u = model.value.homepage.startsWith("http")
        ? model.value.homepage
        : `http://${model.value.homepage}`;
      const url = new URL(u);
      return url.hostname;
    });
    const principalsByRole = computed(() => props.principalsByRole);
    const membershipsToShow = computed(() =>
      [...principalsByRole.value]
        .map(({ role, principals }) => {
          if (!role.assignable || role.is_external) return undefined;
          return {
            role,
            principals,
          };
        })
        .filter((m) => "undefined" !== typeof m),
    );
    const hasModule = (moduleName: string) =>
      enabledModuleNames.value.includes(moduleName);
    const currentUserCan = (action: string) =>
      action in permissions.value &&
      true === permissions.value[action as keyof ProjectPermissions];
    const wiki = computed(() => props.wiki);
    const topLevelWikiPages = computed(() =>
      wiki.value.filter((w) => !w.parent),
    );
    const avatarUrlForPrincipal = (principal: Principal) => {
      if (["group", "group_anonymous"].includes(principal.type)) {
        return `/groups/${principal.id}/avatar`;
      } else {
        return `/users/${principal.id}/avatar`;
      }
    };
    const documents = computed(() => props.documents);
    const documentsByCategory = computed(() =>
      documents.value.reduce(
        (acc, doc) => {
          if (!acc[doc.category]) {
            acc[doc.category] = [];
          }
          acc[doc.category].push(doc);
          return acc;
        },
        {} as Record<string, ProjectDocumentLink[]>,
      ),
    );
    const minDateTime = computed(() => model.value.created_on!);
    const propsForPartial = computed(() => ({
      formAuthenticityToken: props.formAuthenticityToken,
      id: props.id,
      model: props.model,
      members: props.members,
      menu: props.menu,
      issueCategories: props.issueCategories,
      versions: props.versions,
      repositories: props.repositories,
      customFields: props.customFields,
      values: props.values,
      permissions: props.permissions,
      principalsByRole: props.principalsByRole,
      subprojects: props.subprojects,
      news: props.news,
      trackers: props.trackers,
      openIssuesByTracker: props.openIssuesByTracker,
      totalIssuesByTracker: props.totalIssuesByTracker,
      totalHours: props.totalHours,
      totalEstimatedHours: props.totalEstimatedHours,
      gitlabProjects: props.gitlabProjects,
      parents: props.parents,
      wiki: props.wiki,
      documents: props.documents,
      files: props.files,
      mondayBoard: props.mondayBoard,
      surfaceColor: surfaceColor.value,
      accentColor: accentColor.value,
      hasModule,
      currentUserCan,
    }));
    const isCurrentRoute = (names: string[]) => {
      return names.includes(route.name as string);
    };
    return {
      breadcrumbsBindings,
      surfaceColor,
      accentColor,
      projectHeroBindings,
      defaultProjectAvatar,
      avatarSource,
      publicStatusChip,
      status,
      prettifiedHomepage,
      membershipsToShow,
      hasModule,
      currentUserCan,
      topLevelWikiPages,
      iconGitlab,
      iconMonday,
      avatarUrlForPrincipal,
      formatDuration,
      documentsByCategory,
      minDateTime,
      propsForPartial,
      isCurrentRoute,
    };
  },
});
</script>

<style lang="scss">
.page-projects-show {
  .project-hero {
    position: relative;
    display: flex;
    flex-direction: column;

    &:before {
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 50%;
      background-image: var(--project-hero-background);
      background-size: cover;
      opacity: 0.5;
    }

    > div {
      position: relative;
      z-index: 1;
      flex-grow: 1;
      height: 50%;
      width: 100%;
      display: flex;
      align-items: center;
      padding: 0 16px;

      &.bottom {
        align-items: flex-end;
      }

      > .v-avatar {
        border: solid 2px;
        transform: translateY(75px);
      }

      @media (max-width: 600px) {
        justify-content: center;
        > .v-avatar {
          transform: translateY(30px);
        }
      }
    }
  }

  .v-row {
    &.with-dividing-border {
      @media (min-width: 600px) and (max-width: 959px) {
        > div:not(:first-child):not(:last-child) {
          border-right: 1px solid
            rgba(var(--v-theme-on-surface), var(--v-border-opacity));
        }
      }
      @media (min-width: 960px) {
        > div:not(:last-child) {
          border-right: 1px solid
            rgba(var(--v-theme-on-surface), var(--v-border-opacity));
        }
      }
    }
  }

  .v-card.overflow-y-visible {
    overflow: visible !important;
    position: relative;
  }

  .project-card-label {
    position: absolute;
    top: -10px;
    z-index: 3;
    background-color: rgb(var(--v-theme-surface));
    opacity: 1;
    padding: 0 8px;
  }
}
</style>
