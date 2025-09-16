#!/usr/bin/env sh

#
# Copyright 2015 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
DEFAULT_JVM_OPTS=""

APP_NAME="Gradle"
APP_BASE_NAME=`basename "$0"`

# Use the maximum available, or set MAX_FD != -1 to use that value.
MAX_FD="maximum"

warn () {
    echo "$*"
}

die () {
    echo
    echo "$*"
    echo
    exit 1
}

# OS specific support (must be 'true' or 'false').
cygwin=false
msys=false
darwin=false
nonstop=false
case "`uname`" in
  CYGWIN* )
    cygwin=true
    ;;
  Darwin* )
    darwin=true
    ;;
  MINGW* )
    msys=true
    ;;
  NONSTOP* )
    nonstop=true
    ;;
esac

CLASSPATH_SEPARATOR=':'
if [ "$cygwin" = "true" ] || [ "$msys" = "true" ] ; then
    CLASSPATH_SEPARATOR=';'
fi

# Attempt to set APP_HOME
# Resolve links: $0 may be a link
PRG="$0"
# Need this for relative symlinks.
while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`"/$link"
    fi
done
SAVED="`pwd`"
cd "`dirname \"$PRG\"`/" >/dev/null
APP_HOME="`pwd -P`"
cd "$SAVED" >/dev/null

# Add a second backslash to variables to protect them from substitution
APP_ARGS=""
for arg in "$@"; do
    APP_ARGS="$APP_ARGS \"$arg\""
done

# Split up the JVM options passed to the application.
# The following test handles the case where the GRADLE_OPTS variable is not set.
if [ -z "$GRADLE_OPTS" ] ; then
    GRADLE_OPTS=""
fi
# The following test handles the case where the JAVA_OPTS variable is not set.
if [ -z "$JAVA_OPTS" ] ; then
    JAVA_OPTS=""
fi
JVM_OPTS_ARRAY=()
for OPTS in "$GRADLE_OPTS" "$JAVA_OPTS" ; do
    # This loop is because variables in shell cannot contain the NUL character.
    # So we use a temporary file to use xargs to split the options.
    # As a security measure, we create the file in a directory that we create.
    # The directory will be removed at the end of this block.
    if [ -n "$OPTS" ] ; then
        TMP_DIR=`mktemp -d`
        # We do not want to follow symlinks here.
        if [ ! -d "$TMP_DIR" -o -L "$TMP_DIR" ] ; then
            die "Error: Failed to create temporary directory."
        fi
        TMP_FILE="$TMP_DIR/java_opts"
        touch "$TMP_FILE"
        # Make sure that only we can read and write to the file.
        chmod 600 "$TMP_FILE"
        # Disabling the shellcheck hint because we are intentionally splitting the options.
        # shellcheck disable=SC2086
        echo $OPTS > "$TMP_FILE"
        # We do not want to follow symlinks here.
        if [ ! -f "$TMP_FILE" -o -L "$TMP_FILE" ] ; then
            die "Error: Failed to create temporary file."
        fi
        # We read the options from the temporary file.
        # The options are separated by spaces.
        # We use xargs to split the options and store them in an array.
        # The -0 option is used to handle options with spaces.
        # The -n 1 option is used to read one option at a time.
        # The -a option is used to read the options from the file.
        while IFS= read -r -d '' opt; do
            JVM_OPTS_ARRAY+=("$opt")
        done < <(xargs -0 -n 1 -a "$TMP_FILE")
        # We remove the temporary directory and file.
        rm -rf "$TMP_DIR"
    fi
done

# Collect all arguments for the java command, following the shell quoting and substitution rules
eval set -- "$DEFAULT_JVM_OPTS" "${JVM_OPTS_ARRAY[@]}" -Dorg.gradle.appname="$APP_BASE_NAME" -classpath "\"$APP_HOME/gradle/wrapper/gradle-wrapper.jar\"" org.gradle.wrapper.GradleWrapperMain "$@"

# Use the maximum available, or set MAX_FD != -1 to use that value.
if [ "$darwin" != "true" ] && [ "$nonstop" != "true" ] ; then
    # Increase the maximum file descriptors if we can.
    if ! ulimit -n "$MAX_FD" 2>/dev/null ; then
        warn "Could not set maximum file descriptor limit: $MAX_FD"
    fi
fi

# For Darwin, add options to specify how the application appears in the dock
if $darwin; then
    GRADLE_OPTS="$GRADLE_OPTS \"-Xdock:name=$APP_NAME\" \"-Xdock:icon=$APP_HOME/media/gradle.icns\""
fi

# Execute Gradle
# (We must use 'exec' to ensure external signals are received by Gradle)
exec java "$@"
