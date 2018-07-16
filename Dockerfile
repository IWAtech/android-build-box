FROM ubuntu:16.04

ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_NDK  /opt/android-ndk
ENV ANDROID_NDK_HOME /opt/android-ndk


ENV ANDROID_SDK_VERSION="25.2.3"

# Get the latest version from https://developer.android.com/ndk/downloads/index.html
ENV ANDROID_NDK_VERSION="17b"

# Set locale
ENV LANG en_US.UTF-8
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen $LANG

WORKDIR /tmp

# Installing packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        autoconf \
        git \
        curl \
        wget \
        lib32stdc++6 \
        lib32z1 \
        lib32z1-dev \
        lib32ncurses5 \
        libc6-dev \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        libxslt-dev \
        libxml2-dev \
        m4 \
        ncurses-dev \
        ocaml \
        openssh-client \
        pkg-config \
        python-software-properties \
        software-properties-common \
        unzip \
        zip \
        zlib1g-dev && \
    apt-add-repository -y ppa:openjdk-r/ppa && \
    apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/ && \
    apt-get clean

# install node
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -&& \
    apt-get install -yq nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install npm build dependencies
RUN npm install -g npm && \
    npm install --quiet -g npm-check-updates eslint jshint node-gyp gulp bower mocha karma-cli react-native-cli && \
    npm cache clean --force

# Install Android SDK
# Get the latest version from https://developer.android.com/studio/index.html
RUN wget -q -O tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip -q tools.zip && \
    rm -fr $ANDROID_HOME tools.zip && \
    mkdir -p $ANDROID_HOME && \
    mv tools $ANDROID_HOME/tools
    # Install Android components

COPY licenses ${ANDROID_HOME}/licenses

RUN cd $ANDROID_HOME && ls -la tools/bin && tools/bin/sdkmanager \ 
    "build-tools;25.0.3" "build-tools;26.0.2" "build-tools;27.0.3" "build-tools;27.0.2" "build-tools;28.0.1" \
    "extras;android;m2repository" "extras;google;google_play_services" "ndk-bundle" \
    "platform-tools" "platforms;android-28" "platforms;android-27" "platforms;android-26" "platforms;android-25"

# RUN cd $ANDROID_HOME && ls -la && \
#     echo "Install build-tools-28" && \
#     echo y | tools/android --silent update sdk --no-ui --all --filter build-tools-28 && \
#     echo "Install build-tools-26" && \
#     echo y | tools/android --silent update sdk --no-ui --all --filter build-tools-26 && \
#     echo "Install build-tools-25.0.3" && \
#     echo y | tools/android --silent update sdk --no-ui --all --filter build-tools-25.0.3 && \
#     echo "Install extra-android-m2repository" && \
#     echo y | tools/android --silent update sdk --no-ui --all --filter extra-android-m2repository && \
#     echo "Install extra-google-google_play_services" && \
#     echo y | tools/android --silent update sdk --no-ui --all --filter extra-google-google_play_services && \
#     echo "Install extra-google-m2repository" && \
#     echo y | tools/android --silent update sdk --no-ui --all --filter extra-google-m2repository

# Install Android NDK, put it in a separate RUN to avoid travis-ci timeout in 10 minutes.
# Get the latest version from https://developer.android.com/ndk/downloads/index.html
# RUN wget -q -O android-ndk.zip http://dl.google.com/android/repository/android-ndk-r${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
#     unzip -q android-ndk.zip && \
#     rm -fr $ANDROID_NDK android-ndk.zip && \
#     mv android-ndk-r${ANDROID_NDK_VERSION} $ANDROID_NDK

# Add android commands to PATH
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV PATH $PATH:$ANDROID_SDK_HOME/tools:$ANDROID_SDK_HOME/platform-tools:$ANDROID_NDK

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms512m -Xmx1024m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

# Confirms that we agreed on the Terms and Conditions of the SDK itself
# (if we didn’t the build would fail, asking us to agree on those terms).
RUN mkdir "${ANDROID_HOME}/licenses" || true
RUN echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > "${ANDROID_HOME}/licenses/android-sdk-license"

