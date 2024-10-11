<template>
  <v-container class="page-welcome" :fluid="true">
    <h1 class="text-h5 mb-3">{{ $t("labels.home") }}</h1>
    <v-row>
      <v-col cols="12" md="6">
        <Markdown :raw="welcome" />
      </v-col>
      <v-col v-if="news.length > 0" cols="12" md="6">
        <v-card class="news-wrapper" :title="$t('labels.latestNews')">
          <template v-for="(item, i) in news" :key="`news-item-${i}`">
            <v-divider />
            <NewsPreview :news="item" />
          </template>
          <v-card-actions>
            <v-btn variant="text" :to="{ name: 'news' }">{{
              $t("labels.allNews")
            }}</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Markdown } from "@/components/rendering/markdown";
import { NewsPreview } from "@/components/news";
import type { News } from "@/redmine";
import type { PropType } from "vue";
export default defineComponent({
  name: "WelcomeIndex",
  components: {
    Markdown,
    NewsPreview,
  },
  props: {
    welcome: {
      type: String,
      required: true,
    },
    news: {
      type: Array as PropType<News[]>,
      required: true,
    },
  },
});
</script>
