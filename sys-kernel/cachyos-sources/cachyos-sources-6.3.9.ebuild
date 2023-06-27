# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
EXTRAVERSION="-cachyos"
K_SECURITY_UNSUPPORTED="1"
K_EXP_GENPATCHES_NOUSE="1"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="12"
ETYPE="sources"

inherit kernel-2
detect_version

DESCRIPTION="CachyOS are improved kernels, that improve performance and other aspects."

_patchsource="https://raw.githubusercontent.com/cachyos/kernel-patches/master/${KV_MAJOR}.${KV_MINOR}"
_configsource="https://raw.githubusercontent.com/cachyos/linux-cachyos/master"

HOMEPAGE="https://github.com/CachyOS/linux-cachyos"
SRC_URI="
	${KERNEL_URI}
	${GENPATCHES_URI}
	${_patchsource}/all/0001-cachyos-base-all.patch -> 0001-cachyos-base-all-${KV_FULL}.patch
	eevdf? (
		${_patchsource}/sched/0001-EEVDF.patch -> 0001-EEVDF-${KV_FULL}.patch
		${_configsource}/linux-cachyos/config -> config-${KV_FULL}-eevdf
	)
	eevdf-bore? (
		${_patchsource}/sched/0001-EEVDF.patch -> 0001-EEVDF-${KV_FULL}.patch
		${_patchsource}/sched/0001-bore-eevdf.patch -> 0001-bore-eevdf-${KV_FULL}.patch
		${_configsource}/linux-cachyos-eevdf/config -> config-${KV_FULL}-eevdf-bore
	)
	bmq? (
		${_patchsource}/sched/0001-prjc-cachy.patch -> 0001-prjc-cachy-${KV_FULL}.patch
		${_configsource}/linux-cachyos-bmq/config -> config-${KV_FULL}-bmq
	)
	pds? (
		${_patchsource}/sched/0001-prjc-cachy.patch -> 0001-prjc-cachy-${KV_FULL}.patch
		${_configsource}/linux-cachyos-pds/config -> config-${KV_FULL}-pds
	)
	tt? (
		${_patchsource}/sched/0001-tt-cachy.patch -> 0001-tt-cachy-${KV_FULL}.patch
		${_configsource}/linux-cachyos-tt/config -> config-${KV_FULL}-tt
	)
	bore? (
		${_patchsource}/sched/0001-bore-cachy.patch -> 0001-bore-cachy-${KV_FULL}.patch
		${_configsource}/linux-cachyos-bore/config -> config-${KV_FULL}-bore
	)
	cfs? (
		${_configsource}/linux-cachyos-server/config -> config-${KV_FULL}-cfs
	)
	hardened? (
		${_configsource}/linux-cachyos-hardened/config -> config-${KV_FULL}-hardened
	)
	tuned-bore? ( ${_patchsource}/misc/0001-bore-tuning-sysctl.patch ->
				 0001-bore-tuning-sysctl-${KV_FULL}.patch )
	bcachefs? ( ${_patchsource}/misc/0001-bcachefs.patch -> 0001-bcachefs-${KV_FULL}.patch )
	gcc-lto? (
		  ${_patchsource}/misc/gcc-lto/0001-gcc-LTO-support-for-the-kernel.patch ->
			  0001-gcc-LTO-support-for-the-kernel-.${KV_FULL}.patch
		  ${_patchsource}/misc/gcc-lto/0002-gcc-lto-no-pie.patch ->
			  0001-gcc-lto-no-pie-${KV_FULL}.patch
	)
	lrng? ( ${_patchsource}/misc/0001-lrng.patch -> 0001-lrng-${KV_FULL}.patch )
	aufs? ( ${_patchsource}/misc/0001-aufs-6.3-merge-v20230515.patch ->
			  0001-aufs-6.3-merge-v20230515-${KV_FULL}.patch )
	rt? ( ${_patchsource}/misc/0001-rt.patch -> 0001-rt-${KV_FULL}.patch )
	spadfs? ( ${_patchsource}/misc/0001-spadfs-6.3-merge-v1.0.17.patch ->
				0001-spadfs-6.3-merge-v1.0.17-${KV_FULL}.patch )
	sched-task-classes? ( ${_patchsource}/misc/0002-sched-Introduce-classes-of-tasks-for-load-balance.patch ->
							0002-sched-Introduce-classes-of-tasks-for-load-balance-${KV_FULL}.patch )
	sched-avoid-unnecessary-migrations? ( ${_patchsource}/misc/0001-sched-fair-Avoid-unnecessary-migrations-within-SMT-d.patch ->
											0001-sched-fair-Avoid-unnecessary-migrations-within-SMT-d-${KV_FULL}.patch )
	high-hz? ( ${_patchsource}/misc/0001-high-hz.patch -> 0001-high-hz-${KV_FULL}.patch )

"

LICENSE="GPL-2"
SLOT="stable"
KEYWORDS="amd64"
EXPERIMENTAL_IUSE="aufs high-hz rt spadfs sched-task-classes sched-avoid-unnecessary-migrations"
IUSE="bore eevdf eevdf-bore pds bmq tt cfs +cachy +numa +bbr2 +lru +vma damon lrng +debug gcc-lto bcachefs tuned-bore hardened ${EXPERIMENTAL_IUSE}"

REQUIRED_USE="
	^^ ( pds bmq bore cfs tt eevdf eevdf-bore )
	tuned-bore? ( bore eevdf-bore )
	gcc-lto? ( !debug )
	sched-task-classes? ( ^^ ( cfs bore eevdf eevdf-bore ) )
	sched-avoid-unnecessary-migrations? ( ^^ ( cfs bore eevdf eevdf-bore ) )
	high-hz? ( tt )
"

DEPEND="virtual/linux-sources"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	default

	eapply "${DISTDIR}/0001-cachyos-base-all-${KV_FULL}.patch"

	if use eevdf-bore; then
		eapply "${DISTDIR}/0001-EEVDF-${KV_FULL}.patch"
		eapply "${DISTDIR}/0001-bore-eevdf-${KV_FULL}.patch"
	fi

	if use eevdf; then
		eapply "${DISTDIR}/0001-EEVDF-${KV_FULL}.patch"
	fi

	if use pds || use bmq; then
		eapply "${DISTDIR}/0001-prjc-cachy-${KV_FULL}.patch"
	fi

	if use tt; then
		eapply "${DISTDIR}/0001-tt-cachy-${KV_FULL}.patch"

		if use high-hz; then
			eapply "${DISTDIR}/0001-high-hz-${KV_FULL}.patch"
		fi
	fi

	if use bore; then
		eapply "${DISTDIR}/0001-bore-cachy-${KV_FULL}.patch"
	fi

	if (use bore || use eevdf) && use tuned-bore; then
		eapply "${DISTDIR}/0001-bore-tuning-sysctl-${KV_FULL}.patch"
	fi

	if use rt; then
		eapply "${DISTDIR}/0001-rt-${KV_FULL}.patch"
	fi

	if use sched-avoid-unnecessary-migrations; then
		eapply "${DISTDIR}/0001-sched-fair-Avoid-unnecessary-migrations-within-SMT-d-${KV_FULL}.patch"
	fi

	if use sched-task-classes; then
		eapply "${DISTDIR}/0002-sched-Introduce-classes-of-tasks-for-load-balance-${KV_FULL}.patch"
	fi

	if use bcachefs; then
		eapply "${DISTDIR}/0001-bcachefs-${KV_FULL}.patch"
	fi

	if use aufs; then
		eapply "${DISTDIR}/0001-aufs-6.3-merge-v20230515-${KV_FULL}.patch"
	fi

	if use spadfs; then
		eapply "${DISTDIR}/0001-spadfs-6.3-merge-v1.0.17-${KV_FULL}.patch"
	fi

	if use gcc-lto; then
		eapply "${DISTDIR}/0001-gcc-LTO-support-for-the-kernel-${KV_FULL}.patch"
		eapply "${DISTDIR}/0002-gcc-lto-no-pie-${KV_FULL}.patch"
	fi

	if use lrng; then
		eapply "${DISTDIR}/0001-lrng-${KV_FULL}.patch"
	fi

	eapply_user
}

src_configure() {
	default

	# Applying kernel configuration depending on the selected scheduler.
	active_sched = usev hardened || usev cfs || usev bore || usev eevdf || usev eevdf-bore || usev tt || usev pds || usev bmq
	cp "${DISTDIR}/config-${KV_FULL}-${active_sched}"  "${S}/.config"

	# Applying some tweaks from CachyOS.
	if use cachy; then
		"${S}/scripts/config" -e CACHY
	fi

	if use pds; then
		"${S}/scripts/config" -e SCHED_ALT \
							  -d SCHED_BMQ \
							  -e SCHED_PDS \
							  -e PSI_DEFAULT_DISABLED
	fi

	if use bmq; then
		"${S}/scripts/config" -e SCHED_ALT \
							  -e SCHED_BMQ \
							  -d SCHED_PDS \
							  -e PSI_DEFAULT_DISABLED
	fi

	if use tt; then
		"${S}/scripts/config" -e TT_SCHED -e TT_ACCOUNTING_STATS

		# Setting the TT scheduler frequency.
		# For TT, the value of 833 is a balance between performance and latency,
		# which is only available when the high-hz patch is applied.
		if use high-hz; then
			"${S}/scripts/config" -e HZ_833
			"${S}/scripts/config" --set-val HZ 833
		else
			"${S}/scripts/config" -e HZ_1000
			"${S}/scripts/config" --set-val HZ 1000
		fi
	fi

	if use bore || use eevdf; then
		"${S}/scripts/config" -e SCHED_BORE
	fi

	# Setting the scheduler frequency.
	if use pds || use bmq; then
		"${S}/scripts/config" -e HZ_1000
		"${S}/scripts/config" --set-val HZ 1000
	fi

	if use cfs || use bore || use eevdf; then
		"${S}/scripts/config" -e HZ_500
		"${S}/scripts/config" --set-val HZ 500
	fi

	if use gcc-lto; then
		"${S}/scripts/config" -e LTO_GCC -d LTO_CP_CLONE
	fi

	# Disabling NUMA support.
	if ! use numa; then
		"${S}/scripts/config" -d NUMA \
							  -d AMD_NUMA \
							  -d X86_64_ACPI_NUMA \
							  -d NODES_SPAN_OTHER_NODES \
							  -d NUMA_EMU \
							  -d USE_PERCPU_NUMA_NODE_ID \
							  -d ACPI_NUMA \
							  -d ARCH_SUPPORTS_NUMA_BALANCING \
							  -d NODES_SHIFT \
							  -u NODES_SHIFT \
							  -d NEED_MULTIPLE_NODES \
							  -d NUMA_BALANCING \
							  -d NUMA_BALANCING_DEFAULT_ENABLED
	fi

	# Enabling BBR2
	if use bbr2; then
		"${S}/scripts/config" -m TCP_CONG_CUBIC \
							  -d DEFAULT_CUBIC \
							  -e TCP_CONG_BBR2 \
							  -e DEFAULT_BBR2 \
							  --set-str DEFAULT_TCP_CONG bbr2

		# BBR2 does not work together with FQ_CODEL, so the latter must be disabled
		"${S}/scripts/config" -m NET_SCH_FQ_CODEL \
							  -e NET_SCH_FQ \
							  -d DEFAULT_FQ_CODEL \
							  -e DEFAULT_FQ \
							  --set-str DEFAULT_NET_SCH fq
	fi

	# Disabling LRU
	if ! use lru; then
		"${S}/scripts/config" -d LRU_GEN \
							  -d LRU_GEN_ENABLED \
							  -d LRU_GEN_STATS
	fi

	# Enabling per-VMA lock
	if use vma; then
		"${S}/scripts/config" -e PER_VMA_LOCK \
							  -d PER_VMA_LOCK_STATS
	fi

	# Enabling DAMON
	if use damon; then
		"${S}/scripts/config" -e DAMON \
							  -e DAMON_VADDR \
							  -e DAMON_DBGFS \
							  -e DAMON_SYSFS \
							  -e DAMON_PADDR \
							  -e DAMON_RECLAIM \
							  -e DAMON_LRU_SORT
	fi

	# Enabling and configuring LRNG
	if use lrng; then
		"${S}/scripts/config" -e LRNG \
							  -e LRNG_SHA256 \
							  -e LRNG_COMMON_DEV_IF \
							  -e LRNG_DRNG_ATOMIC \
							  -e LRNG_SYSCTL \
							  -e LRNG_RANDOM_IF \
							  -e LRNG_AIS2031_NTG1_SEEDING_STRATEGY \
							  -m LRNG_KCAPI_IF \
							  -m LRNG_HWRAND_IF \
							  -e LRNG_DEV_IF \
							  -e LRNG_RUNTIME_ES_CONFIG \
							  -e LRNG_IRQ_DFLT_TIMER_ES \
							  -d LRNG_SCHED_DFLT_TIMES_ES \
							  -e LRNG_TIMER_COMMON \
							  -d LRNG_COLLECTION_SIZE_256 \
							  -d LRNG_COLLECTION_SIZE_512 \
							  -e LRNG_COLLECTION_SIZE_1024 \
							  -d LRNG_COLLECTION_SIZE_2048 \
							  -d LRNG_COLLECTION_SIZE_4096 \
							  -d LRNG_COLLECTION_SIZE_8192 \
							  --set-val LRNG_COLLECTION_SIZE 1024 \
							  -e LRNG_HEALTH_TESTS \
							  --set-val LRNG_RCT_CUTOFF 31 \
							  --set-val LRNG_APT_CUTOFF 325 \
							  -e LRNG_IRQ \
							  -e LRNG_CONTINUOUS_COMPRESSION_ENABLED \
							  -d LRNG_CONTINUOUS_COMPRESSION_DISABLED \
							  -e LRNG_ENABLE_CONTINUOUS_COMPRESSION \
							  -e LRNG_SWITCHABLE_CONTINUOUS_COMPRESSION \
							  --set-val LRNG_IRQ_ENTROPY_RATE 256 \
							  -e LRNG_JENT \
							  --set-val LRNG_JENT_ENTROPY_RATE 16 \
							  -e LRNG_CPU \
							  --set-val LRNG_CPU_FULL_ENT_MULTIPLIER 1 \
							  --set-val LRNG_CPU_ENTROPY_RATE 8 \
							  -e LRNG_SCHED \
							  --set-val LRNG_SCHED_ENTROPY_RATE 4294967295 \
							  -e LRNG_DRNG_CHACHA20 \
							  -m LRNG_DRBG \
							  -m LRNG_DRNG_KCAPI \
							  -e LRNG_SWITCH \
							  -e LRNG_SWITCH_HASH \
							  -m LRNG_HASH_KCAPI \
							  -e LRNG_SWITCH_DRNG \
							  -m LRNG_SWITCH_DRBG \
							  -m LRNG_SWITCH_DRNG_KCAPI \
							  -e LRNG_DFLT_DRNG_CHACHA20 \
							  -d LRNG_DFLT_DRNG_DRBG \
							  -d LRNG_DFLT_DRNG_KCAPI \
							  -e LRNG_TESTING_MENU \
							  -d LRNG_RAW_HIRES_ENTROPY \
							  -d LRNG_RAW_JIFFIES_ENTROPY \
							  -d LRNG_RAW_IRQ_ENTROPY \
							  -d LRNG_RAW_RETIP_ENTROPY \
							  -d LRNG_RAW_REGS_ENTROPY \
							  -d LRNG_RAW_ARRAY \
							  -d LRNG_IRQ_PERF \
							  -d LRNG_RAW_SCHED_HIRES_ENTROPY \
							  -d LRNG_RAW_SCHED_PID_ENTROPY \
							  -d LRNG_RAW_SCHED_START_TIME_ENTROPY \
							  -d LRNG_RAW_SCHED_NVCSW_ENTROPY \
							  -d LRNG_SCHED_PERF \
							  -d LRNG_ACVT_HASH \
							  -d LRNG_RUNTIME_MAX_WO_RESEED_CONFIG \
							  -d LRNG_TEST_CPU_ES_COMPRESSION \
							  -e LRNG_SELFTEST \
							  -d LRNG_SELFTEST_PANIC \
							  -d LRNG_RUNTIME_FORCE_SEEDING_DISABLE
	fi

	# Disabling most of basic debugging features
	if ! use debug; then
		"${S}/scripts/config" -d DEBUG_INFO \
							  -d DEBUG_INFO_BTF \
							  -d DEBUG_INFO_DWARF4 \
							  -d DEBUG_INFO_DWARF5 \
							  -d PAHOLE_HAS_SPLIT_BTF \
							  -d DEBUG_INFO_BTF_MODULES \
							  -d SLUB_DEBUG \
							  -d PM_DEBUG \
							  -d PM_ADVANCED_DEBUG \
							  -d PM_SLEEP_DEBUG \
							  -d ACPI_DEBUG \
							  -d SCHED_DEBUG \
							  -d LATENCYTOP \
							  -d DEBUG_PREEMT
	fi

	"${S}/scripts/config" -e USER_NS

}

pkg_postinst() {
	kernel-2_pkg_postinst

	if use bmq || use pds; then
		ewarn "You install the linux-cachyos kernel variant with the PDS/BMQ scheduler."
		ewarn "Please note that this scheduler can cause various performance and stability"
		ewarn "issues (especially on AMD Ryzen CPUs) and cachyos developers don't provide official"
		ewarn "support for fixing them. If you encounter any problems while using the kernel,"
		ewarn "please make sure that that it is not a BMQ or PDS specific problem before reporting it"
		ewarn "to them, otherwise inform the Project C developer:"
		ewarn "https://gitlab.com/alfredchen/linux-prjc/-/issues"
		ewarn " "
	fi
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
