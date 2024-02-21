// @ts-check

import { promises as fs } from 'node:fs'
import { dirname, join as pathJoin } from 'node:path'
import { fileURLToPath } from 'node:url'

import { unified } from 'unified'
import remarkParse from 'remark-parse'
import remarkFrontmatter from 'remark-frontmatter'
import remarkGfm from 'remark-gfm'
import remarkRehype from 'remark-rehype'
import rehypeStringify from 'rehype-stringify'
import rehypeSlug from 'rehype-slug'
import rehypeAutolinkHeadings from 'rehype-autolink-headings'

import addClasses from './addClasses.js'
import { defaultValue } from './utils.js'

const currentDir = dirname(fileURLToPath(import.meta.url))

const LOCALS_PLUGIN_KEY = 'markdown-content-plugin'

/**
 * Return a HTML string from a Markdown string.
 *
 * @param {string} markdownString Markdown string
 * @param {Record<string, any>} config configuration
 * @returns HTML string
 */
const convertToHtml = async (markdownString, config) => {
  const processors = [
    [remarkParse],
    [remarkFrontmatter],
    [remarkGfm],
    [remarkRehype],
    [rehypeSlug, {
      prefix: config.idPrefix,
    }],
  ]

  if (config.autoLink) {
    // @ts-ignore
    processors.push([rehypeAutolinkHeadings, {
      // @ts-ignore
      behavior: 'wrap',
      properties: {
        class: 'headers-autolink',
      },
    }])
  }

  processors.push([addClasses, config.classes])
  processors.push([rehypeStringify])

  const processor = unified()
  for (const [plugin, options] of processors) {
    // @ts-ignore
    processor.use(plugin, options)
  }

  const html = await processor.process(markdownString)

  return html.toString()
}

/**
 * Get all subdirectories of that particular directory.
 *
 * @param {string} path path of the starting directory
 * @returns list of all directories present in that directory
 */
const getItems = async (path) => {
  const directories = []

  const pathContent = await fs.readdir(path, { withFileTypes: true })

  for (const item of pathContent) {
    if (!item.isDirectory()) {
      continue
    }
    const fullPath = pathJoin(path, item.name)
    directories.push({
      name: item.name,
      path: fullPath,
    })
  }

  return directories
}

/**
 * Read all markdown files from a directory and convert them in HTML format.
 *
 * @param {string} path path of the directory to read
 * @param {Record<string, any>} config configuration
 * @returns list of files that are in that directory
 */
const getContent = async (path, config) => {
  const files = []

  const pathContent = await fs.readdir(path, { withFileTypes: true })

  for (const item of pathContent) {
    if (item.isDirectory()) {
      continue
    }
    const fullPath = pathJoin(path, item.name)
    if (!fullPath.endsWith('.md')) {
      continue
    }

    const content = await fs.readFile(fullPath, 'utf-8')
    const html = await convertToHtml(content, config)
    files.push({
      language: item.name.replace(/\.md*/, ''),
      path: fullPath,
      html,
    })
  }

  return files
}

/**
 * Return all keys for the specific language.
 *
 * @param {Record<string, any>} store
 * @param {string} language
 * @returns
 */
const entriesForLanguage = (store, language = 'en') => {
  const finalStore = {}

  for (const [key, item] of Object.entries(store)) {
    let value = null
    let fallbackValue = null

    // eslint-disable-next-line array-callback-return
    item.map((item) => {
      if (item.language === language) {
        value = item.html
      }
      if (item.language === 'default') {
        fallbackValue = item.html
      }
    })

    if (value === null && fallbackValue !== null) {
      value = fallbackValue
    }

    if (value === null) {
      value = ''
    }

    finalStore[key] = value
  }

  return finalStore
}

/** @type {import('../../core/types/index.js').TrifidMiddleware} */
const factory = async (trifid) => {
  const { config, logger, server, render } = trifid

  const locals = server.locals
  if (!locals) {
    throw new Error('locals not found')
  }

  if (!locals.has(LOCALS_PLUGIN_KEY)) {
    locals.set(LOCALS_PLUGIN_KEY, {})
  }

  const entries = config?.entries || {}
  const defaults = config?.defaults || {}

  // Default configuration
  const idPrefix = defaultValue('idPrefix', defaults, 'content-')
  const classes = defaultValue('classes', defaults, {})
  const autoLink = defaultValue('autoLink', defaults, true)
  const template = defaultValue('template', defaults, `${currentDir}/../views/content.hbs`)

  // Iterate over all configured entries
  for (const [namespace, entry] of Object.entries(entries)) {
    const directory = entry?.directory
    const mountPath = entry?.mountPath || false

    // check config
    if (!directory || typeof directory !== 'string') {
      throw new Error('\'directory\' should be a non-empty string')
    }

    const contentConfiguration = {
      idPrefix: defaultValue('idPrefix', entry, idPrefix),
      classes: defaultValue('classes', entry, classes),
      autoLink: defaultValue('autoLink', entry, autoLink),
    }

    const store = {}
    const items = await getItems(directory)

    for (const item of items) {
      store[item.name] = await getContent(item.path, contentConfiguration)
    }

    server.addHook('onRequest', (_request, _reply, done) => {
      const currentLanguage = locals.get('currentLanguage') || 'en'
      logger.debug(`loaded store into '${namespace}' namespace (lang=${currentLanguage})`)
      const currentContent = locals.get(LOCALS_PLUGIN_KEY) || {}
      currentContent[namespace] = entriesForLanguage(store, currentLanguage)
      locals.set(LOCALS_PLUGIN_KEY, currentContent)
      done()
    })

    // create a route for each entry
    if (mountPath) {
      const mountAtPathSlash = mountPath.endsWith('/') ? mountPath : `${mountPath}/`

      for (const item of items) {
        /**
         * Route handler for the specific content.
         * @param {import('fastify').FastifyRequest} _request Request.
         * @param {import('fastify').FastifyReply} reply Reply.
         * @returns {Promise<void>}
         */
        const routeHandler = async (_request, reply) => {
          reply.send(await render(defaultValue('template', entry, template), {
            content: locals.get(LOCALS_PLUGIN_KEY)?.[namespace]?.[item.name] || '',
          }))
        }
        server.get(`${mountAtPathSlash}${item.name}`, routeHandler)
      }
    }
  }
}

export default factory
