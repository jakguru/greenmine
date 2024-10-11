<template>
  <v-list-item three-line>
    <v-list-item-subtitle v-if="news.project && !inProject">
      <router-link v-bind="projectRouterLinkBindings">
        <small class="font-weight-bold">{{ news.project.name }}</small>
      </router-link>
    </v-list-item-subtitle>
    <v-list-item-title>
      <router-link v-bind="newsRouterLinkBindings">
        <strong>{{ title }}</strong>
      </router-link>
    </v-list-item-title>
    <v-list-item-subtitle v-if="summary">
      <div class="py-2 font-italic">{{ summary }}</div>
    </v-list-item-subtitle>
    <v-list-item-subtitle>
      <i18n-t keypath="generics.addedLine" tag="small" class="font-weight-thin">
        <template #author>
          <router-link v-bind="authorRouterLinkBindings">
            {{ authorDisplayName }}
          </router-link>
        </template>
        <template #when>
          &nbsp;<abbr :title="createdOnFormatted">{{ createdOnRelative }}</abbr>
        </template>
      </i18n-t>
    </v-list-item-subtitle>
    <template #append>
      <v-badge color="primary" overlap>
        <template #badge>{{ commentsCount }}</template>
        <v-avatar v-if="commentsCount > 0" icon="mdi-comment" />
      </v-badge>
    </template>
  </v-list-item>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { RouterLink } from "vue-router";
import { DateTime } from "luxon";
import type { News } from "@/redmine";
import type { PropType } from "vue";
export default defineComponent({
  name: "NewsPreview",
  components: {
    RouterLink,
  },
  props: {
    news: {
      type: Object as PropType<News>,
      required: true,
    },
    inProject: {
      type: Boolean,
      default: false,
    },
  },
  setup(props) {
    const news = computed(() => props.news);
    const id = computed(() => news.value.id);
    const title = computed(() => news.value.title);
    const summary = computed(() => news.value.summary);
    const createdOn = computed(() => news.value.created_on);
    const commentsCount = computed(() => news.value.comments_count);
    const project = computed(() => news.value.project);
    const author = computed(() => news.value.author);
    const createdOnRelative = computed(() =>
      DateTime.fromISO(createdOn.value).toRelative(),
    );
    const createdOnFormatted = computed(() =>
      DateTime.fromISO(createdOn.value).toLocaleString(DateTime.DATETIME_MED),
    );
    const projectRouterLinkBindings = computed(() => ({
      to: { name: "projects-id", params: { id: project.value?.identifier } },
    }));
    const newsRouterLinkBindings = computed(() => ({
      to: { name: "news-id", params: { id: id.value } },
    }));
    const authorRouterLinkBindings = computed(() => ({
      to: { name: "users-id", params: { id: author.value.id } },
    }));
    const authorDisplayName = computed(() => {
      const ret = [author.value.firstname, author.value.lastname]
        .filter((v) => v)
        .map((v) => v.trim())
        .join(" ");
      return ret || author.value.login;
    });
    return {
      projectRouterLinkBindings,
      newsRouterLinkBindings,
      title,
      summary,
      authorRouterLinkBindings,
      authorDisplayName,
      createdOnRelative,
      createdOnFormatted,
      commentsCount,
    };
  },
});
</script>
