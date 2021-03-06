#!/bin/bash -xe

package="aeon"

pushd `dirname $0` > /dev/null
myDir=`pwd`
popd > /dev/null

localRepoDir="${myDir}/build_artefacts"

logsDir="${myDir}/build_logs"
mkdir -p "${logsDir}"

cd ${myDir}

# Build the metapackage tracking the feature (only)
conda build ${package}-cuda-feature \
      --output-folder ${localRepoDir} \
      &> >(tee ${logsDir}/${package}-cuda-feature.log)

# Rerender the main recipe
conda-smithy rerender &> >(tee ${logsDir}/conda-smithy-rerender.log)

# Build the main package
dockerScript="${myDir}/ci_support/run_docker_build.sh"
${dockerScript} &> >(tee ${logsDir}/${package}.log)

# Build the meta package tracking the feature and installing the main package
conda build ${package}-cuda \
      --output-folder ${localRepoDir} \
      --channel file://${localRepoDir} \
      &> >(tee ${logsDir}/${package}-cuda.log)

# Fertig
set +x
echo "All done, please upload the new artifacts in ${localRepoDir} to anaconda.org like:"
echo "  " `cat ${logsDir}/${package}-cuda-feature.log | grep "anaconda upload"`
echo "  " `cat ${logsDir}/${package}.log | grep "anaconda upload"`
echo "  " `cat ${logsDir}/${package}-cuda.log | grep "anaconda upload"`
echo "add \"-u {channel}\" to upload to a different organization (e.g. \"-u loopbio\")."
echo "
Do not forget to build the CPU version of the package (in the \"cpu\" branch).

--- Fertig ---
"

#
# --- Notes
#
# Make the local repo the highest priority channel
#   sed -i "/channels:/a \ - file:///feedstock_root/build_artefacts" ${dockerScript}
# This is at the moment not needed, as it is the default in conda-build
# (I solved a problem that did not exist).
# In case they change that, just uncomment this line:
# If so, maybe do not do inplace, but create a temp script and delete after completion.
#
