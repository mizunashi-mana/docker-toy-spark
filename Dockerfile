FROM openjdk:8-jre

ENV SPARK_VERSION="2.4.3" \
    SPARK_CHECKSUM="e8b7f9e1dec868282cadcad81599038a22f48fb597d44af1b13fcc76b7dacd2a1caf431f95e394e1227066087e3ce6c2137c4abaf60c60076b78f959074ff2ad" \
    SPARK_INSTALL_DIR="/opt/spark" \
    HADOOP_VERSION="2.7.7" \
    HADOOP_CHECKSUM="17c8917211dd4c25f78bf60130a390f9e273b0149737094e45f4ae5c917b1174b97eb90818c5df068e607835120126281bcc07514f38bd7fd3cb8e9d3db1bdde" \
    HADOOP_INSTALL_DIR="/opt/hadoop"

ENV SPARK_HOME="${SPARK_INSTALL_DIR}" \
    SPARK_CONF_DIR="${SPARK_HOME}/conf" \
    HADOOP_HOME="${HADOOP_INSTALL_DIR}" \
    HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
   apt-utils locales wget \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && locale-gen en_US.UTF-8 \
 && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --system --create-home --home-dir "${HADOOP_HOME}" hadoop \
 && mkdir -p "${HADOOP_INSTALL_DIR}" \
 && cd "${HADOOP_INSTALL_DIR}" \
 && wget -q -O "${HADOOP_INSTALL_DIR}/hadoop.tgz" "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
 && sha512sum "hadoop.tgz" | grep "${HADOOP_CHECKSUM}" \
 && tar -xz --strip 1 -f "hadoop.tgz" \
 && chown -R hadoop:hadoop "${HADOOP_HOME}"

RUN useradd --system --create-home --home-dir "${SPARK_HOME}" spark \
 && mkdir -p "${SPARK_INSTALL_DIR}" \
 && cd "${SPARK_INSTALL_DIR}" \
 && wget -q -O "${SPARK_INSTALL_DIR}/spark-bin-hadoop.tgz" "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION%.*}.tgz" \
 && sha512sum "spark-bin-hadoop.tgz" | grep "${SPARK_CHECKSUM}" \
 && tar -xz --strip 1 -f "spark-bin-hadoop.tgz" \
 && chown -R spark:spark "${SPARK_HOME}"

COPY scripts/entrypoint.bash /sbin/entrypoint.bash
RUN chmod 755 /sbin/entrypoint.bash

ENV PATH="${SPARK_INSTALL_DIR}/bin:${PATH}" \
    LD_LIBRARY_PATH="${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH}"

WORKDIR /opt/spark
USER spark

ENTRYPOINT [ "/sbin/entrypoint.bash" ]
CMD ["master"]
