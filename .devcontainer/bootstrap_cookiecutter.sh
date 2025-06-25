#!/bin/bash
set -ex

WORKSPACE_ROOT="/workspaces"
GENERATED_DIR="$WORKSPACE_ROOT/tmp-new-project"
MARKER_FILE="$WORKSPACE_ROOT/.cookiecutter_initialized"

if [ ! -f "$MARKER_FILE" ]; then
  echo "🔨 Bootstrapping a new project with cookiecutter..."
  
  apt-get update && apt-get install -y python3-pip git
  pip install cookiecutter
  
  cd "$WORKSPACE_ROOT"
  
  if [ "$NEW_PROJECT_MODE" = "yes_edge_system" ]; then
    cookiecutter git@github.com:PicnicSupermarket/picnic-analyst-development-platform.git \
      --directory "project-templates/edge-workflow" \
      --no-input \
      project_name="$PROJECT_NAME" \
      project_title="$PROJECT_TITLE" \
      project_short_description="$PROJECT_SHORT_DESCRIPTION" \
      git_repo_name="$GIT_REPO_NAME" \
      github_team_name="$GITHUB_TEAM_NAME" \
      authors="$AUTHORS" \
      kubernetes_namespace="$KUBERNETES_NAMESPACE" \
      output_dir="$GENERATED_DIR"
  else
    cookiecutter git@github.com:PicnicSupermarket/picnic-analyst-development-platform.git \
      --directory "project-templates/edge-ui" \
      --no-input \
      project_name="$PROJECT_NAME" \
      project_title="$PROJECT_TITLE" \
      project_short_description="$PROJECT_SHORT_DESCRIPTION" \
      git_repo_name="$GIT_REPO_NAME" \
      github_team_name="$GITHUB_TEAM_NAME" \
      authors="$AUTHORS" \
      kubernetes_namespace="$KUBERNETES_NAMESPACE" \
      create_example_page="$CREATE_EXAMPLE_PAGE" \
      output_dir="$GENERATED_DIR"
  fi
  
  touch "$MARKER_FILE"
  echo "✅ Project created at $GENERATED_DIR."
  echo "⚠️  Please restart your workspace to finalize setup."
  tail -f /dev/null
  exit 0
fi

if [ -f "$MARKER_FILE" ] && [ -d "$GENERATED_DIR" ]; then
  echo "🚚 Moving generated project to workspace root..."
  rsync -a --remove-source-files "$GENERATED_DIR/" "$WORKSPACE_ROOT/"
  rm -rf "$GENERATED_DIR"
  rm -f "$MARKER_FILE"
fi

echo "Starting Code-Server..."

curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server

unset NEXUS_USERNAME
unset NEXUS_PASSWORD
unset DBT_ENV_SECRET_NEXUS_PASSWORD

if [ -f ".devcontainer/devcontainer.json" ]; then
  EXTENSIONS=$(sed '/^ *\\/\\//d' .devcontainer/devcontainer.json | jq -r '.customizations.vscode.extensions[]?')
  for EXTENSION in $EXTENSIONS; do
    /tmp/code-server/bin/code-server --install-extension $EXTENSION || echo "Installation of extension $EXTENSION failed. Skipping."
  done
fi

/tmp/code-server/bin/code-server \
--disable-workspace-trust \
--disable-telemetry \
--disable-update-check \
--disable-getting-started-override \
--link-protection-trusted-domains keycloak-dev.global.picnicinternational.com \
--link-protection-trusted-domains accounts.google.com \
--auth none \
--port 13337 >/tmp/code-server.log 2>&1 &
tail -f /dev/null
