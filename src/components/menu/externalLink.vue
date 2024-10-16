<template>
  <a v-bind="linkBindings">
    <div class="pa-3 pb-1">
      <v-sheet v-bind="iconWrapperBindings">
        <v-responsive
          :aspect-ratio="1"
          class="friday-external-menu-link__icon-responsive-wrapper"
        >
          <v-icon v-bind="iconBindings">{{ icon }}</v-icon>
        </v-responsive>
      </v-sheet>
    </div>
    <div v-bind="labelWrapperBindings">{{ label }}</div>
  </a>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
export default defineComponent({
  name: "MenuExternalLink",
  components: {},
  props: {
    to: {
      type: String,
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
    const to = computed(() => props.to);
    const linkBindings = computed(() => ({
      class: ["friday-external-menu-link"],
      href: to.value,
      target: "_blank",
    }));
    const color = computed(() => props.color);
    const iconWrapperBindings = computed(() => ({
      rounded: true,
      elevation: 2,
      color: color.value,
    }));
    const iconSize = computed(() => props.iconSize);
    const iconBindings = computed(() => ({
      size: iconSize.value,
    }));
    const labelWrapperBindings = computed(() => ({
      class: ["friday-external-menu-link__label", "text-center"],
      style: {
        "--menu-link-color": `var(--v-theme-on-${color.value})`,
      },
    }));
    return {
      linkBindings,
      iconWrapperBindings,
      iconBindings,
      labelWrapperBindings,
    };
  },
});
</script>

<style lang="scss">
.friday-external-menu-link {
  display: flex;
  flex-direction: column;
  width: 100%;
  text-decoration: none;
  font-size: 12px;
  font-weight: 600;
  color: var(--menu-link-color);

  .friday-external-menu-link__icon-responsive-wrapper {
    > .v-responsive__content {
      display: flex;
      align-items: center;
      justify-content: center;
    }
  }
}
</style>
