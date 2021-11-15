FROM nanobox/windows-env

LABEL "name"="Windows Signing Utility"
LABEL "maintainer"="Joseph Chen"
LABEL "version"="0.0.3"

LABEL "com.github.actions.name"="Windows Signing Utility"
LABEL "com.github.actions.description"="Windows Signing Utility"
LABEL "com.github.actions.icon"="lock"
LABEL "com.github.actions.color"="blue"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]