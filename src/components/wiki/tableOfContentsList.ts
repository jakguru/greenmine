/* eslint-disable vue/one-component-per-file */
import { defineComponent, ref, computed, h, watch } from "vue";
import { useRoute } from "vue-router";
import { VList, VListItem } from "vuetify/components/VList";
import { VBtn } from "vuetify/components/VBtn";
import { VIcon } from "vuetify/components/VIcon";
import type { PropType, VNode } from "vue";
import type { WikiTableOfContents } from "@/friday";

export const TableOfContentsListItem = defineComponent({
  name: "WikiTableOfContentsListItem",
  props: {
    item: {
      type: Object as PropType<WikiTableOfContents>,
      required: true,
    },
    level: {
      type: Number,
      default: 0,
    },
  },
  setup(props) {
    const item = computed(() => props.item);
    const level = computed(() => props.level);
    const route = useRoute();
    const open = ref(false);
    const toReturn = computed(() => {
      const ret: VNode[] = [];
      if (!item.value.children) {
        ret.push(
          h(
            VListItem,
            {
              id: `wiki-toc-${item.value.id}`,
              title: item.value.title,
              to: item.value.path,
            },
            {
              prepend: () =>
                0 === level.value
                  ? ""
                  : h(
                      VIcon,
                      { class: [`ms-${level.value}`] },
                      "mdi-subdirectory-arrow-right",
                    ),
            },
          ),
        );
      } else {
        const children = computed<WikiTableOfContents[]>(
          () => item.value.children as WikiTableOfContents[],
        );
        ret.push(
          h(
            VListItem,
            {
              id: `wiki-toc-${item.value.id}`,
              title: item.value.title,
              to: item.value.path,
            },
            {
              prepend: () =>
                0 === level.value
                  ? ""
                  : h(
                      VIcon,
                      { class: [`ms-${level.value}`] },
                      "mdi-subdirectory-arrow-right",
                    ),
              append: () =>
                h(VBtn, {
                  icon: open.value ? "mdi-chevron-up" : "mdi-chevron-down",
                  variant: "text",
                  onClick: (event: MouseEvent) => {
                    event.preventDefault();
                    open.value = !open.value;
                  },
                }),
            },
          ),
        );
        if (open.value) {
          ret.push(
            ...[...children.value].map((child) =>
              h(TableOfContentsListItem, {
                item: child,
                level: level.value + 1,
              }),
            ),
          );
        }
      }
      return ret;
    });
    const doesPathMatchRoute = (path: string, routePath: string) => {
      const pathUrlObj = new URL(path, window.location.origin);
      const routePathUrlObj = new URL(routePath, window.location.origin);
      return pathUrlObj.pathname === routePathUrlObj.pathname;
    };
    watch(
      () => route.path,
      (is) => {
        if (
          item.value.children &&
          item.value.children.some((child) =>
            doesPathMatchRoute(child.path, is),
          )
        ) {
          open.value = true;
        }
      },
      { immediate: true },
    );
    return () => toReturn.value;
  },
});

export const TableOfContentsList = defineComponent({
  name: "WikiTableOfContentsList",
  props: {
    toc: {
      type: Array as PropType<WikiTableOfContents[]>,
      required: true,
    },
  },
  setup(props) {
    const items = computed(() => props.toc);
    return () =>
      h(
        VList,
        {
          nav: true,
        },
        [...items.value].map((item) => h(TableOfContentsListItem, { item })),
      );
  },
});
