# Dual boot Windows and Debian with LVM

Documentation on how to partition a single disk to use Windows and Debian (with LVM) in the same machine. This article should be double checked. I had a really bad time trying to do this and I was able to do it after several attempts, but not really sure how.

## Summary

Install Windows 10.

In Windows, open the Disk Management tool (`diskmgmt.msc`). Shrink the Windows partition if you need. I just needed to use 60 GB.

Start the Debian installation with graphical interface. Once you get to the partitioning part, choose Manual Partitioning and then create (or modify if you have already created some of them) these partitions:

- mounting as "/boot", sized 256MB, EXT2, Boot-able;
- one partition, taking up the rest of the space of the drive, as a volume for LVM;
- create one logical volume the same size as the physical RAM in your system i.e. 8GB, name it "Swap", use as swap, format;
- another logical volume: mounting as "/" (root), choose the size you want, EXT4, format.

Finish the installation. It should install GRUB.

## References

- [How do I create a multiboot environment using LVM for your *buntu operating systems on a GPT formatted system drive, in a UEFI based system?](https://askubuntu.com/a/226982) by CW at askubuntu.com
- [DualBoot Windows](https://wiki.debian.org/DualBoot/Windows) at wiki.debian.org
- [How to install debian alongside Windows (dual boot) with full disk encryption](https://ertugrulharman.com/en/2017/09/06/how-to-install-debian-alongside-windows-dual-boot-with-full-disk-encryption/) by Ertugrul Harman at ertugrulharman.com
- [How to dual boot Windows 10 and Debian 10](https://www.linuxtechi.com/dual-boot-windows-10-debian-10/) by James Kiarie at linuxtechi.com
