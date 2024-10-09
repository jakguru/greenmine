import { inject } from 'vue'
import { createWebHistory, createRouter } from 'vue-router'
import { loadRouteData } from '@/utils/app'
import { useRouteDataStore } from '@/stores/routeData'
import type { RouteRecordRaw } from 'vue-router'
import type {
  ApiService,
  ToastService,
} from "@jakguru/vueprint";

const fourOhFour = () => import('@/views/404.vue');

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: () => import('@/pages/welcome/index.vue'),
  },
  {
    path: '/login',
    name: 'login',
    // component: () => import('@/pages/login/index.vue'),
    component: fourOhFour,
  },
  {
    path: '/logout',
    name: 'logout',
    // component: () => import('@/pages/logout/index.vue'),
    component: fourOhFour,
  },
  {
    path: '/account',
    // component: () => import('@/pages/account/index.vue'),
    component: fourOhFour,
    children: [
      {
        path: 'twofa/confirm',
        name: 'account-twofa-confirm',
        // component: () => import('@/pages/account/twofaconfirm.vue'),
        component: fourOhFour,
      },
      {
        path: 'activate',
        name: 'account-activate',
        // component: () => import('@/pages/account/activate.vue'),
        component: fourOhFour,
      },
      {
        path: 'activation_email',
        name: 'account-activation-email',
        // component: () => import('@/pages/account/activationemail.vue'),
        component: fourOhFour,
      },
    ],
  },
  {
    path: '/news/preview',
    name: 'news-preview',
    // component: () => import('@/pages/news/preview.vue'),
    component: fourOhFour,
  },
  {
    path: '/issues/preview',
    name: 'issues-preview',
    // component: () => import('@/pages/issues/preview.vue'),
    component: fourOhFour,
  },
  {
    path: '/projects/:id/wiki/destroy',
    name: 'projects-id-wiki-destroy',
    // component: () => import('@/pages/projects/wiki/destroy.vue'),
    component: fourOhFour,
  },
  {
    path: '/boards/:board_id/topics/new',
    name: 'boards-board_id-topics-new',
    // component: () => import('@/pages/boards/topics/new.vue'),
    component: fourOhFour,
  },
  {
    path: '/boards/:board_id/topics/:id',
    name: 'boards-board_id-topics-id',
    // component: () => import('@/pages/boards/topics/show.vue'),
    component: fourOhFour,
  },
  {
    path: '/boards/:board_id/topics/:id/edit',
    name: 'boards-board_id-topics-id-edit',
    // component: () => import('@/pages/boards/topics/edit.vue'),
    component: fourOhFour,
  },
  {
    path: '/projects/:project_id/issues/gantt',
    name: 'projects-project_id-issues-gantt',
    // component: () => import('@/pages/projects/issues/gantt.vue'),
    component: fourOhFour,
  },
  {
    path: '/issues/gantt',
    name: 'issues-gantt',
    // component: () => import('@/pages/issues/gantt.vue'),
    component: fourOhFour,
  },
  {
    path: '/projects/:project_id/issues/calendar',
    name: 'projects-project_id-issues-calendar',
    // component: () => import('@/pages/projects/issues/calendar.vue'),
    component: fourOhFour,
  },
  {
    path: '/issues/calendar',
    name: 'issues-calendar',
    // component: () => import('@/pages/issues/calendar.vue'),
    component: fourOhFour,
  },
  {
    path: '/projects/:id/issues/report',
    name: 'projects-id-issues-report',
    // component: () => import('@/pages/projects/issues/report.vue'),
    component: fourOhFour,
  },
  {
    path: '/projects/:id/issues/report/:detail',
    name: 'projects-id-issues-report-detail',
    // component: () => import('@/pages/projects/issues/reportdetail.vue'),
    component: fourOhFour,
  },
  {
    path: '/imports/:id',
    name: 'imports-id',
    // component: () => import('@/pages/imports/show.vue'),
    component: fourOhFour,
  },
  {
    path: '/my/account',
    name: 'my-account',
    // component: () => import('@/pages/my/account/index.vue'),
    component: fourOhFour,
  },
  {
    path: '/my/page',
    name: 'my-page',
    // component: () => import('@/pages/my/page/index.vue'),
    component: fourOhFour,
  },
  {
    path: '/my/api_key',
    name: 'my-api-key',
    // component: () => import('@/pages/my/apikey.vue'),
    component: fourOhFour,
  },
  {
    path: '/projects/:id/issues/report',
    name: 'projects-id-issues-report',
    // component: () => import('@/pages/projects/issues/report.vue'),
    component: fourOhFour,
  },
  {
    path: '/users',
    name: 'users',
    // component: () => import('@/pages/users/index.vue'),
    component: fourOhFour,
  },
  {
    path: '/users/context_menu',
    name: 'users-context-menu',
    // component: () => import('@/pages/users/contextmenu.vue'),
    component: fourOhFour,
  },
  {
    path: '/projects/:id/repository/:repository_id/revision',
    name: 'projects-id-repository-repository_id-revision',
    // component: () => import('@/pages/projects/repository/revision.vue'),
    component: fourOhFour,
  },
  {
    path: '/projects/:id/repository/:repository_id/show/*path',
    name: 'projects-id-repository-repository_id-show-path',
    // component: () => import('@/pages/projects/repository/show.vue'),
    component: fourOhFour,
  },
  {
    path: '/attachments/:id/:filename',
    name: 'attachments-id-filename',
    // component: () => import('@/pages/attachments/show.vue'),
    component: fourOhFour,
  },
  {
    path: '/attachments/download/:id/:filename',
    name: 'attachments-download-id-filename',
    // component: () => import('@/pages/attachments/download.vue'),
    component: fourOhFour,
  },
  {
    path: '/groups/:id/users/new',
    name: 'groups-id-users-new',
    // component: () => import('@/pages/groups/users/new.vue'),
    component: fourOhFour,
  },
  {
    path: '/projects/:id/activity',
    name: 'projects-id-activity',
    // component: () => import('@/pages/projects/activity/index.vue'),
    component: fourOhFour,
  },
  {
    path: '/admin',
    name: 'admin-index',
    // component: () => import('@/pages/admin/index.vue'),
    component: fourOhFour,
  },
  {
    path: '/admin/projects',
    name: 'admin-projects',
    // component: () => import('@/pages/admin/projects/index.vue'),
    component: fourOhFour,
  },
  {
    path: '/admin/plugins',
    name: 'admin-plugins',
    // component: () => import('@/pages/admin/plugins/index.vue'),
    component: fourOhFour,
  },
  {
    path: '/admin/info',
    name: 'admin-info',
    // component: () => import('@/pages/admin/info/index.vue'),
    component: fourOhFour,
  },
  {
    path: '/search',
    name: 'search',
    // component: () => import('@/pages/search/index.vue'),
    component: fourOhFour,
  },
];

export const router = createRouter({
    history: createWebHistory(),
    routes,
})
  

router.beforeEach( async (to) => {
  const api = inject<ApiService>("api");
  const toast = inject<ToastService>("toast");
  const props = await loadRouteData(to, api, toast)
  if ('boolean' === typeof props) {
    return props
  }
  const store = useRouteDataStore()
  store.set(props)
})