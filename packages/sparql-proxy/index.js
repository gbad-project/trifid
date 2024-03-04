// @ts-check

const defaultConfiguration = {
  endpointUrl: '',
  username: '',
  password: '',
}

/**
 * Generate the value for the Authorization header for basic authentication.
 *
 * @param {string} user The username.
 * @param {string} password The password of that user.
 * @returns {string} The value of the Authorization header to use.
 */
const authBasicHeader = (user, password) => {
  const base64String = Buffer.from(`${user}:${password}`).toString('base64')
  return `Basic ${base64String}`
}

/** @type {import('../core/types/index.js').TrifidMiddleware} */
const factory = async (trifid) => {
  const { logger, config } = trifid

  const options = { ...defaultConfiguration, ...config }
  if (!options.endpointUrl) {
    throw Error('Missing endpointUrl parameter')
  }

  let authorizationHeader = ''
  if (options.username && options.password) {
    authorizationHeader = authBasicHeader(options.username, options.password)
  }

  return {
    defaultConfiguration: async () => {
      return {
        methods: ['GET', 'POST'],
        paths: [
          '/query',
          '/query/',
        ],
      }
    },
    routeHandler: async () => {
      /**
       * Query string type.
       *
       * @typedef {Object} QueryString
       * @property {string} [query] The SPARQL query.
       */

      /**
       * Request body type.
       * @typedef {Object} RequestBody
       * @property {string} [query] The SPARQL query.
       */

      /**
       * Route handler.
       * @param {import('fastify').FastifyRequest<{ Querystring: QueryString, Body: RequestBody | string }>} request Request.
       * @param {import('fastify').FastifyReply} reply Reply.
       */
      const handler = async (request, reply) => {
        const fullUrl = `${request.protocol}://${request.hostname}${request.raw.url}`
        const fullUrlObject = new URL(fullUrl)
        const fullUrlPathname = fullUrlObject.pathname

        // Enforce non-trailing slash
        if (fullUrlPathname.slice(-1) === '/') {
          return reply.redirect(`${fullUrlPathname.slice(0, -1)}`)
        }

        let query = ''
        switch (request.method) {
          case 'GET':
            query = request.query.query
            break
          case 'POST':
            if (typeof request.body === 'string') {
              query = request.body
            }

            if (typeof request.body !== 'string' && request.body.query) {
              query = request.body.query
            }

            if (typeof query !== 'string') {
              query = JSON.stringify(query)
            }

            break
          default:
            return reply.code(405).send('Method Not Allowed')
        }

        logger.debug('Got a request to the sparql proxy')

        logger.debug(`Received query: ${query}`)

        try {
          const acceptHeader = request.headers.accept || 'application/sparql-results+json'
          const headers = {
            'Content-Type': 'application/x-www-form-urlencoded',
            Accept: acceptHeader,
          }
          if (authorizationHeader) {
            headers.Authorization = authorizationHeader
          }
          const response = await fetch(options.endpointUrl, {
            method: 'POST',
            headers,
            body: new URLSearchParams({ query }),
          })

          const contentType = response.headers.get('content-type')
          return reply.status(response.status).header('content-type', contentType).send(response.body)
        } catch (error) {
          logger.error('Error while querying the endpoint')
          logger.error(error)
          return reply.code(500).send('Error while querying the endpoint')
        }
      }
      return handler
    },
  }
}

export default factory
