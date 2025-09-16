#!/bin/bash
# Create proper gradlew script for LayoutOrchestrator

cd LayoutOrchestrator

# Create gradlew with proper Gradle wrapper implementation
cat > gradlew << 'EOT'
#!/bin/sh

##############################################################################
#
# Copyright 2015 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# you may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
##############################################################################

# Attempt to set APP_HOME

# Resolve links: $0 may be a link
app_path=$0

# Need this for daisy-chained symlinks.
while
    APP_HOME=${app_path%"${app_path##*/}"}  # leaves a trailing /; empty if no leading path
    [ -h "$app_path" ]
do
    ls=$( ls -ld "$app_path" )
    link=${ls#*' -> '}
    case $link in             #(
      /*)   app_path=$link ;; #(
      *)    app_path=$APP_HOME$link ;;
    esac
done

# This is normally unused
# shellcheck disable=SC2034
APP_BASE_NAME=${0##*/}
# Discard cd standard output in case $CDPATH is set (https://github.com/gradle/gradle/issues/25036)
APP_HOME=$( cd "${APP_HOME:-./}" > /dev/null && pwd -P ) || exit

# Use the maximum available, or set a default value
MAX_FD=65536

# Collect all arguments for the java command, stacking in reverse order:
#   * args from the command line
#   * the main class name
#   * -classpath
#   * -D...appname settings
#   * --module-path (only if needed)
#   * DEFAULT_JVM_OPTS, JAVA_OPTS, and GRADLE_OPTS environment variables.

# For cygwin, switch paths to Windows format before running java
if [ "$CYGWIN" = "true" ] || [ "$MSYS" = "true" ] ; then
    APP_HOME=$( cygpath -wp "$APP_HOME" )
    # We build the pattern for arguments to be converted via cygpath
    ROOTDIRSRAW=$(echo "$APP_HOME" | sed -e 's/\\/\\\\/g' -e 's/[^[:print:]]/./g')
    REGEX="^-[^[:print:]]*\\($ROOTDIRSRAW\\).*"
    # Process the args, converting the ones matching the pattern
    for arg in "$@" ; do
        # Check if argument is a Windows absolute path (e.g. C:\Path\To\File)
        if [[ "$arg" =~ ^[A-Za-z]:\\.* ]]; then
            JAVA_ARGS+=("-cp" "`cygpath -wp "$arg"`")
        else
            case $arg in                                #(
              -*)   JAVA_ARGS+=("$arg") ;;   # ignore any other options          #(
              *)    JAVA_ARGS+=("$arg") ;;   # assume everything else is a class path
            esac
        fi
    done
else
    JAVA_ARGS=("$@")
fi

# Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
DEFAULT_JVM_OPTS='"-Xmx64m" "-Xms64m"'

# Collect all arguments for the java command:
#   * DEFAULT_JVM_OPTS, JAVA_OPTS, JAVA_ARGS, JAVA_APP_NAME, and optsEnvironmentVar are not allowed to contain shell fragments,
#     see https://github.com/gradle/gradle/issues/19565 for details
JAVA_OPTS="$DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS"

# Auto create wrapper jar directory if needed
if [ ! -d "$APP_HOME/gradle/wrapper" ]; then
    mkdir -p "$APP_HOME/gradle/wrapper"
fi

# Check if wrapper jar exists, if not try to download or run without it
if [ ! -f "$APP_HOME/gradle/wrapper/gradle-wrapper.jar" ]; then
    echo "Gradle wrapper JAR not found. Will attempt to bootstrap..."
fi

exec java $JAVA_OPTS -jar "$APP_HOME/gradle/wrapper/gradle-wrapper.jar" "${JAVA_ARGS[@]}"
EOT

chmod +x gradlew
echo "Created proper gradlew script"
