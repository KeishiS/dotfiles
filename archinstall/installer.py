from pathlib import Path
from typing import Optional

import archinstall
from archinstall import info
from archinstall.lib.configuration import ConfigurationOutput
from archinstall.lib.installer import Installer
from archinstall.lib import disk
from archinstall.lib import locale
from archinstall.lib.models import AudioConfiguration
from archinstall.lib.models.network_configuration import NetworkConfiguration
from archinstall.lib.profile.profiles_handler import profile_handler

config_output = ConfigurationOutput(archinstall.arguments)
config_output.show()
mountpoint = Path("/mnt")

disk_config: disk.DiskLayoutConfiguration = archinstall.arguments["disk_config"]
disk_encryption: disk.DiskEncryption = archinstall.arguments.get("disk_encryption", None)

with Installer(
    mountpoint, disk_config, disk_encryption,
    kernels=archinstall.arguments.get("kernels", ["linux"])
) as installation:
    installation.sanity_check()
    if mirror_config := archinstall.arguments.get("mirror_config", None):
        installation.set_mirrors(mirror_config, on_target=False)

    if archinstall.arguments.get("swap"):
        installation.setup_swap("zram")

    installation.append_mod("vfat")
    installation._hooks.append("lvm2")
    installation._hooks.append("ykfde")
    installation._hooks.append("encrypt")

    installation.add_bootloader(
        archinstall.arguments["bootloader"],
        archinstall.arguments.get('uki', False)
    )

    network_config: Optional[NetworkConfiguration] = archinstall.arguments.get('network_config', None)

    if network_config:
        network_config.install_network_config(
            installation,
            archinstall.arguments.get('profile_config', None)
        )

    if users := archinstall.arguments.get('!users', None):
        installation.create_users(users)

    audio_config: Optional[AudioConfiguration] = archinstall.arguments.get('audio_config', None)
    if audio_config:
        audio_config.install_audio_config(installation)
    else:
        info("No audio server will be installed")

    if archinstall.arguments.get('packages', None) and archinstall.arguments.get('packages', None)[0] != '':
        installation.add_additional_packages(archinstall.arguments.get('packages', None))

    if profile_config := archinstall.arguments.get('profile_config', None):
        profile_handler.install_profile_config(installation, profile_config)

    if timezone := archinstall.arguments.get('timezone', None):
        installation.set_timezone(timezone)

    if archinstall.arguments.get('ntp', False):
        installation.activate_time_synchronization()

    if (root_pw := archinstall.arguments.get('!root-password', None)) and len(root_pw):
        installation.user_set_pw('root', root_pw)

    if profile_config := archinstall.arguments.get('profile_config', None):
        profile_config.profile.post_install(installation)

    if archinstall.arguments.get('services', None):
        installation.enable_service(archinstall.arguments.get('services', []))

    if archinstall.arguments.get('custom-commands', None):
        archinstall.run_custom_user_commands(archinstall.arguments['custom-commands'], installation)

    installation.genfstab()

    locale_config: locale.LocaleConfiguration = archinstall.arguments['locale_config']

    installation.minimal_installation(
        mkinitcpio=run_mkinitcpio,
        hostname=archinstall.arguments.get('hostname', 'archlinux'),
        locale_config=locale_config
    )
