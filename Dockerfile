FROM node:alpine AS node
COPY package.json .
COPY package-lock.json .
RUN npm install

FROM clojure:openjdk-16-tools-deps-alpine
RUN adduser -D conduit
USER conduit
WORKDIR /home/conduit
COPY --chown=conduit . .
COPY --from=node --chown=conduit node_modules node_modules
RUN clojure -A:shadow-cljs release conduit \
 && clojure -A:shadow run shadow.cljs.build-report conduit target/report.html \
 && mkdir classes \
 && clojure -Dclojure.main.report=stderr -e "(compile 'conduit.server)"
CMD ["clojure", "-Dclojure.main.report=stderr", "-J-Xmx1G", "-m", "conduit.server"]
