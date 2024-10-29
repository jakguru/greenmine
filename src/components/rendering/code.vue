<template>
  <v-hover>
    <template #default="{ isHovering, props }">
      <v-card v-bind="{ ...wrapperBinding, ...props }">
        <div class="d-flex px-3">
          <v-spacer />
          <small style="opacity: 0.53">{{ mode }}</small>
        </div>
        <v-fade-transition>
          <v-fab
            v-show="Boolean(isHovering)"
            v-bind="fabBinding"
            @click="onCopy"
          ></v-fab>
        </v-fade-transition>
        <VAceEditor ref="aceEditor" v-bind="binding" @init="onInit" />
      </v-card>
    </template>
  </v-hover>
</template>

<script lang="ts">
import "./plugins/ace";
import { defineComponent, computed, ref, inject } from "vue";
import { useTheme } from "vuetify";
import { VAceEditor } from "vue3-ace-editor";
import { useI18n } from "vue-i18n";
import type { Ace } from "ace-builds";
import type { AceMode } from "./plugins/ace";
import type { PropType } from "vue";
import type { ToastService } from "@jakguru/vueprint";

export default defineComponent({
  name: "RenderCode",
  components: {
    VAceEditor,
  },
  props: {
    content: {
      type: String,
      required: true,
    },
    mode: {
      type: String as PropType<AceMode>,
      default: "text",
    },
    showLineNumbers: {
      type: Boolean,
      default: true,
    },
  },
  setup(props) {
    const theme = useTheme();
    const { t } = useI18n({ useScope: "global" });
    const toast = inject<ToastService>("toast");
    const mode = computed(() => props.mode);
    const showLineNumbers = computed(() => props.showLineNumbers);
    const themeIsDark = computed(
      () => theme.global.name.value === "friday-dark",
    );
    const aceEditor = ref<any | null>(null);
    const content = computed(() => props.content);
    const lines = computed(() => content.value.split("\n").length);
    const binding = computed(() => ({
      maxLines: lines.value,
      readonly: true,
      wrap: false,
      theme: themeIsDark.value ? "monokai" : "dreamweaver",
      lang: mode.value,
      options: {
        useWorker: true,
        showPrintMargin: false,
        showGutter: showLineNumbers.value,
      },
      value: content.value,
    }));
    const wrapperBinding = computed(() => ({
      color: themeIsDark.value ? "#272822" : "#FFFFFF",
      class: ["position-relative", "friday-code-preview"],
    }));
    const onInit = (editor: Ace.Editor) => {
      if (editor) {
        // noop
      }
    };
    const fabBinding = computed(() => ({
      absolute: true,
      border: 1,
      rounded: "sm",
      color: themeIsDark.value ? "#272822" : "#FFFFFF",
      elevation: 3,
      icon: "mdi-content-copy",
      class: ["friday-code-preview__fab"],
    }));
    const onCopy = async () => {
      try {
        await navigator.clipboard.writeText(content.value);
        if (toast) {
          toast.fire({
            title: t("labels.success"),
            text: t("successes.copy"),
            icon: "success",
          });
        }
      } catch (err) {
        if (toast) {
          toast.fire({
            title: t("labels.error"),
            text: t("errors.copy.failed.caught", [(err as Error).message]),
            icon: "error",
          });
        }
      }
    };
    return {
      aceEditor,
      binding,
      onInit,
      wrapperBinding,
      fabBinding,
      onCopy,
    };
  },
});
</script>

<style lang="scss">
.friday-code-preview {
  .friday-code-preview__fab {
    top: 40px;
    right: 15px;
  }
}
</style>
