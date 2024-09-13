import sys
from pathlib import Path

import numpy as np

from phylib.io.model import load_model
from phylib.io.array import _spikes_per_cluster
from phylib.utils._misc import write_tsv


def create_cluster_info(
    params_py: Path
):
    """Load a Phy model from a dir containing params.py, and save a cluster_info.tsv like Phy template-gui would.

    We can use this script to act like Phy template-gui, but in a noninteractive / unattended way.
    It will generate a cluster_info.tsv similar to what you'd get if you
        - open template-gui
        - save (ctrl-s)
        - exited right away

    This seems pointless, but Phy creates a useful file called cluster_info.tsv as a side-effect.
    This script creates a similar cluster_info.tsv with columns including:
        - cluster_id: index of sorted cluster
        - n_spikes: the count of spikes assigned to each each cluster
        - ch: the "best" probe channel among the templates, among the spikes, for each cluster
        - group: curated group for each cluster like "unsorted" (default), "mua", "noise", "good"
        - other metrics found in cluster_*.tsv files like "isi_violations_ratio", "snr", etc

    The code in this script is based on Phy code in:
        - phylib (https://github.com/cortex-lab/phylib)
        - phy (https://github.com/cortex-lab/phy)

    This all seems well-defined and reasonable to script.
    However, we did have to get into the GUI code to find the implementation, which is not ideal!
    """

    print(f"Loading Phy model from {params_py}")
    model = load_model(params_py)
    model.describe()

    # Phy has a couple of ways to get a channel associated with each cluster.
    # For example model.clusters_channels or model.templates_channels.
    #
    # See:
    #   https://github.com/cortex-lab/phylib/blob/master/phylib/io/model.py#L1250
    #
    # However, it looks like template-gui takes a different approach for cluster_info.tsv:
    #   - For a given cluster, look at all its spikes.
    #   - Among all those spikes, look for the most frequently used template.
    #   - For that template, take the channel with the highest amplitude.
    #
    # See:
    #   https://github.com/cortex-lab/phylib/blob/master/phylib/io/model.py#L283
    #   https://github.com/cortex-lab/phy/blob/master/phy/apps/base.py#L983
    #   https://github.com/cortex-lab/phy/blob/master/phy/apps/template/gui.py#L148
    #   https://github.com/cortex-lab/phylib/blob/master/phylib/io/model.py#L897

    # Group sorted spikes by cluster_id.
    #
    # See:
    #   https://github.com/cortex-lab/phylib/blob/master/phylib/io/array.py#L334
    spikes_per_cluster = _spikes_per_cluster(model.spike_clusters)

    # Get the most frequent template from among all the spikes assigned to the given cluster.
    #
    # See:
    #   https://github.com/cortex-lab/phy/blob/master/phy/apps/base.py#L489
    def get_template_for_cluster(cluster_id):
        spike_ids = spikes_per_cluster[cluster_id]
        st = model.spike_templates[spike_ids]
        template_ids, counts = np.unique(st, return_counts=True)
        ind = np.argmax(counts)
        return template_ids[ind]

    # Get the highet-amplitude channel for the most frequent template for spikes in the given cluster.
    #
    # See:
    #   https://github.com/cortex-lab/phylib/blob/master/phylib/io/model.py#L897
    def best_channel_for_cluster(cluster_id):
        template_id = get_template_for_cluster(cluster_id)
        template = model.get_template(template_id)
        return template.channel_ids[0]

    # Based on functions and notes above, pick the "best" channel for each cluster, AKA "ch".
    best_channels = [best_channel_for_cluster(cluster_id) for cluster_id in model.cluster_ids]

    # Using the same grouping of spikes into clusters above, also get "n_spikes".
    n_spikes = [len(spikes_per_cluster[cluster_id]) for cluster_id in model.cluster_ids]

    # Gather up per-cluster metadata.
    cluster_count = len(model.cluster_ids)
    cluster_metadata = {name: data for name, data in model.metadata.items() if len(data) == cluster_count}
    cluster_metadata["cluster_id"] = model.cluster_ids
    cluster_metadata["ch"] = best_channels
    cluster_metadata["n_spikes"] = n_spikes

    print(f"Cluster metadata keys: {cluster_metadata.keys()}")

    # Rotate metadata from a dict of lists to a list of dicts.
    cluster_info = []
    for cluster_index in range(cluster_count):
        row = {key: value[cluster_index] for key, value in cluster_metadata.items()}
        cluster_info.append(row)

    print(f"Info for first cluster: {cluster_info[0]}")

    # Write metadata to cluster_info.tsv.
    # See:
    #   https://github.com/cortex-lab/phy/blob/master/phy/apps/base.py#L1165
    cluster_info_tsv = Path(params_py.parent, "cluster_info.tsv")
    print(f"Writing cluster info to {cluster_info_tsv}")
    write_tsv(
        cluster_info_tsv,
        cluster_info,
        first_field='cluster_id',
        n_significant_figures=8
    )

    model.close()


if __name__ == "__main__":
    # Usage: python3 create_cluster_info.py params.py"
    params_py = Path(sys.argv[1])
    create_cluster_info(params_py)
