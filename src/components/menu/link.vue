<template>
  <RouterLink v-bind="linkBindings">
    <template #default="{ isActive }">
      <div class="pa-3 pb-1">
        <v-sheet
          v-bind="iconWrapperBindings"
          :color="isActive ? activeColor : color"
        >
          <v-responsive
            :aspect-ratio="1"
            class="friday-menu-link__icon-responsive-wrapper"
          >
            <v-icon v-bind="iconBindings">{{ icon }}</v-icon>
          </v-responsive>
        </v-sheet>
      </div>
      <div
        class="text-center"
        :style="{
          '--menu-link-color': `var(--v-theme-on-${isActive ? activeColor : color})`,
        }"
      >
        {{ label }}
      </div>
    </template>
  </RouterLink>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { RouterLink } from "vue-router";
import type {
  RouterLinkProps,
  RouteLocationAsRelativeGeneric,
  RouteLocationAsPathGeneric,
} from "vue-router";
import type { PropType } from "vue";
export default defineComponent({
  name: "MenuLink",
  components: {
    RouterLink,
  },
  props: {
    activeClass: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    ariaCurrentValue: {
      type: String as PropType<RouterLinkProps["ariaCurrentValue"]>,
      default: "page",
    },
    exactActiveClass: {
      type: String as PropType<string | undefined>,
      default: undefined,
    },
    replace: {
      type: Boolean,
      default: false,
    },
    to: {
      type: [String, Object] as PropType<
        string | RouteLocationAsPathGeneric | RouteLocationAsRelativeGeneric
      >,
      required: true,
    },
    icon: {
      type: String,
      default: "mdi-question",
    },
    iconSize: {
      type: Number,
      default: 48,
    },
    color: {
      type: String,
      default: "secondary",
    },
    activeColor: {
      type: String,
      default: "accent",
    },
    label: {
      type: String,
      default: "Menu Link",
    },
  },
  setup(props) {
    const activeClass = computed(() => props.activeClass);
    const ariaCurrentValue = computed(() => props.ariaCurrentValue);
    const exactActiveClass = computed(() => props.exactActiveClass);
    const replace = computed(() => props.replace);
    const to = computed(() => props.to);
    const linkBindings = computed<RouterLinkProps>(() => ({
      class: ["friday-menu-link"],
      activeClass: activeClass.value,
      ariaCurrentValue: ariaCurrentValue.value,
      exactActiveClass: exactActiveClass.value,
      replace: replace.value,
      to: to.value,
    }));
    const iconWrapperBindings = computed(() => ({
      rounded: true,
      elevation: 2,
    }));
    const iconSize = computed(() => props.iconSize);
    const iconBindings = computed(() => ({
      size: iconSize.value,
    }));
    return {
      linkBindings,
      iconWrapperBindings,
      iconBindings,
    };
  },
});
</script>

<style lang="scss">
.friday-menu-link {
  display: flex;
  flex-direction: column;
  width: 100%;
  text-decoration: none;
  font-size: 12px;
  font-weight: 600;
  color: var(--menu-link-color);

  .friday-menu-link__icon-responsive-wrapper {
    > .v-responsive__content {
      display: flex;
      align-items: center;
      justify-content: center;
    }
  }
}
</style>
