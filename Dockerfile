# Base Flutter image
FROM ghcr.io/cirruslabs/flutter:3.24.0

# Install Android Command-Line Tools
USER root
RUN apt-get update && apt-get install -y wget unzip

# Download commandline tools
RUN mkdir -p /android-sdk/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip \
    && unzip tools.zip -d /android-sdk/cmdline-tools \
    && rm tools.zip

# Create folder required by SDK
RUN mkdir -p /android-sdk/cmdline-tools/latest \
    && mv /android-sdk/cmdline-tools/cmdline-tools/* /android-sdk/cmdline-tools/latest

# Set environment variables
ENV ANDROID_SDK_ROOT=/android-sdk
ENV PATH=$PATH:/android-sdk/cmdline-tools/latest/bin:/android-sdk/platform-tools:/android-sdk/emulator

# Accept licenses
RUN yes | sdkmanager --licenses

# Install required SDK components
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Flutter build section
WORKDIR /app
COPY . .
RUN flutter clean
RUN flutter pub get
RUN flutter pub run build_runner build --delete-conflicting-outputs
RUN flutter build apk --release --split-per-abi

CMD ["bash"]
