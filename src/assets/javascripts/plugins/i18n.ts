import { createI18n } from 'vue-i18n'
import * as messages from '@/locales'

const getHtmlLocale = () => {
    if (document) {
        const html = document.querySelector('html')
        if (html) {
            return html.getAttribute('lang') || 'en'
        }
    }
    return 'en'
}

export const i18n = createI18n({
    locale: getHtmlLocale(),
    fallbackLocale: 'en',
    legacy: false,
    messages,
})