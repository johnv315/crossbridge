# $FreeBSD: src/lib/libmilter/Makefile,v 1.8.2.1.6.1 2010/12/21 17:09:25 kensmith Exp $

.include <bsd.own.mk>

SENDMAIL_DIR=${.CURDIR}/../../contrib/sendmail
.PATH:	${SENDMAIL_DIR}/libmilter ${SENDMAIL_DIR}/libsm

CFLAGS+=-I${SENDMAIL_DIR}/src -I${SENDMAIL_DIR}/include -I.
CFLAGS+=-DNOT_SENDMAIL -Dsm_snprintf=snprintf
CFLAGS+=-D_THREAD_SAFE
CFLAGS+=-DSM_CONF_POLL

.if ${MK_INET6_SUPPORT} != "no"
CFLAGS+=-DNETINET6
.endif

# User customizations to the sendmail build environment
CFLAGS+=${SENDMAIL_CFLAGS}

INCSDIR=${INCLUDEDIR}/libmilter
INCS=	${SENDMAIL_DIR}/include/libmilter/mfapi.h \
	${SENDMAIL_DIR}/include/libmilter/mfdef.h
LIB=	milter

SRCS+=	sm_os.h
SRCS+=	main.c engine.c listener.c handler.c comm.c monitor.c smfi.c \
	signal.c sm_gethost.c errstring.c strl.c worker.c
CLEANFILES+=sm_os.h

sm_os.h:
	ln -sf ${SENDMAIL_DIR}/include/sm/os/sm_os_freebsd.h sm_os.h

.include <bsd.lib.mk>
