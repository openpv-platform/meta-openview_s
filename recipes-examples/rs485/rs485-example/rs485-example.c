/*
 * Copyright (C) Helios Technologies
 *
 * Authors: Steve Livingston <stephen.livingston@hlioengineering.com>
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <linux/serial.h>
#include <fcntl.h>
/* Include definition for RS485 ioctls: TIOCGRS485 and TIOCSRS485 */
#include <sys/ioctl.h>
#include <termios.h>
#include <signal.h>

#define DEVICE_NAME		"/dev/ttySTM1"

static char *OPEN_BANNER = "\nRS-485 echo example\n";
static char *CLOSE_BANNER = "\nProgram Terminated.\n\n";
static char *BACKSPACE_MSG = "\nBackspace detected\n";
static char *USAGE_MSG = "Usage: rs485-example [-c | -r | -h] [-b baud-rate]\n";
static char *DESC_USAGE_MSG = \
		"A terminal program to validate the RS-485 interface. The program will \n" \
		"echo back to the RS-485 interface what it receives. \n" \
		"Default behavior is a non-canonical terminal emulation (every character will \n" \
		"be echoed twice). Other options are canonical (every character echoed + echo \n" \
		"the entire line after a carriage return), or raw echo mode. \n" \
		"Default connection parameters are: 115200 baud N81. \n" \
		"Test using a terminal program like putty or minicom.\n" \
		"Exit with the <backspace> key. Putty users may need to use <shift><backspace>\n";
static char *OPTIONS_USAGE_MSG = \
		"  Options:\n" \
		"  -b   : baud rate (accepts 9600 and 115200)\n" \
		"  -c   : turn on canonical mode\n" \
		"  -r   : use raw mode\n" \
		"  -h   : help message\n";

static volatile sig_atomic_t keep_running = 1;

struct options 
{
	int raw;
	int canonical;
	int baud;
};

static int open_device();
static int init_device(int fd, struct options *opts, struct termios *save_termio);
static int close_device(int fd, struct termios *save_termio);
static void parse_opts(int argc, char **argv, struct options *opts);
static void display_opts(struct options *opts);
static void sig_handler(int _);

int main(int argc, char **argv)
{
	int fd, r, w;
	char c;
	time_t start_s, cur_s, prev_s = 0;
	struct options opts;
	struct termios save_termio;

	signal(SIGINT, sig_handler);

	// Defaults:
	opts.raw = 0;
	opts.canonical = 0;
	opts.baud = 115200;
	parse_opts(argc, argv, &opts);

	display_opts(&opts);

	fd = open_device();
	if (fd < 0) {
		printf("\nError [%d] opening device " DEVICE_NAME "\n", fd);
		return(fd);
	}

	r = init_device(fd, &opts, &save_termio);
	if (r < 0) {
		printf("\nError [%d] initializing RS-485 device.\n", r);
		return r;
	}

	printf(OPEN_BANNER);
	w = write(fd, OPEN_BANNER, strlen(OPEN_BANNER));
	if (w < 0) {
		printf("\nError [%d] writing '%s' to RS-485 device.\n", w, OPEN_BANNER);
	}

	start_s = time(NULL);
	while (keep_running) {
		r = read(fd, &c, sizeof(c));
		if (r < 0 && errno != EAGAIN) {
			printf("\n Read error [%d]", r);
			break;
		} else if (r == 1) {
			if ( c == 0x08 ) {
				write(fd, BACKSPACE_MSG, strlen(BACKSPACE_MSG));
				printf(BACKSPACE_MSG);
				break;
			}
			w = write(fd, &c, sizeof(c));
			if (w < 0) {
				printf("\nError [%d] writing RS-485 device.\n", w);
				break;
			}
		}
		cur_s = time(NULL);
		// Display a `.` every second to indicate program is running
		if (cur_s > prev_s) {
			c = '.';
			write(fd, &c, sizeof(c));
			printf("%i s\n", cur_s - start_s);
			prev_s = cur_s;
		}
	}

	write(fd, CLOSE_BANNER, strlen(CLOSE_BANNER));
	printf(CLOSE_BANNER);

	close_device(fd, &save_termio);

	return(0);
}

static int open_device()
{
	int fd = open (DEVICE_NAME, O_RDWR | O_NONBLOCK | O_NDELAY);
	return fd;
}

static int init_device(int fd, struct options *opts, struct termios *save_termio)
{
	struct serial_rs485 rs485conf;
	struct termios termio;
	int r;

	if (fd < 0) {
		printf("Bad file descriptor [%d]", fd);
		return fd;
	}

	/* Configure RS485 */
  /*******************/
	rs485conf.flags |= SER_RS485_ENABLED;

	/* Set logical level for RTS pin equal to 1 when sending: */
	rs485conf.flags |= SER_RS485_RTS_ON_SEND;
	/* or, set logical level for RTS pin equal to 0 when sending: */
	// rs485conf.flags &= ~(SER_RS485_RTS_ON_SEND);

	/* Set logical level for RTS pin equal to 1 after sending: */
	// rs485conf.flags |= SER_RS485_RTS_AFTER_SEND;
	/* or, set logical level for RTS pin equal to 0 after sending: */
	rs485conf.flags &= ~(SER_RS485_RTS_AFTER_SEND);

	/* enable bus termination if supported */
	// rs485conf.flags |= SER_RS485_TERMINATE_BUS;

	/* Set rts delay before send, if needed: */
	rs485conf.delay_rts_before_send = 60;

	/* Set rts delay after send, if needed: */
	rs485conf.delay_rts_after_send = 60;

	/* Set this flag if you want to receive data even while sending data */
	// rs485conf.flags |= SER_RS485_RX_DURING_TX;

	r = ioctl (fd, TIOCSRS485, &rs485conf);
	if(r < 0) {
		/* ioctl error */
		r = errno;
		printf("Error [%d] setting ioctl", r);
		return r;
	}

	r = tcgetattr(fd, &termio);
	if ( r == 0 ) {
		if (save_termio)
			memcpy(save_termio, &termio, sizeof(struct termios));
		if (opts->raw) {
			cfmakeraw(&termio);
		} else if (opts->canonical) {
			/* Turn on canonical mode */
			termio.c_lflag |= ICANON;
		} else {
			/* Turn off canonical mode by default */
			termio.c_lflag &= ~ICANON;
		}
		cfsetspeed(&termio, opts->baud == 9600 ? B9600 : B115200);
		r = tcsetattr(fd, TCSAFLUSH, &termio);
	}
	if ( r < 0) {
		r = errno;
		printf("Error [%d] setting terminal attributes.", r);
	}

	return r;
}

static int close_device(int fd, struct termios *save_termio)
{
	if (save_termio)
		tcsetattr(fd, TCSAFLUSH, save_termio);
	if (close (fd) < 0) {
		printf("Error closing device.");
	}
}

static void display_opts(struct options *opts)
{
	printf("\nSettings: 8N1 @ %d baud in %s mode.\n",
			opts->baud,
			opts->raw ? "raw" : opts->canonical ? "canonical" : "non-canonical" );
	printf("Execute with 'rs485-example -h' to see more options.\n");
}

static void parse_opts(int argc, char **argv, struct options *opts)
{
	int c, index;
	int hflag = 0;
	int eflag = 0;
	char *s_baud = NULL;
	int baud;

	opterr = 0;

	// Parse known:
	while ((c = getopt (argc, argv, "crhb:")) != -1) {
		switch (c)
		{
			case 'c':
				opts->canonical = 1;
				break;
			case 'r':
				opts->raw = 1;
				break;
			case 'h':
				hflag = 1;
				break;
			case 'b':
				s_baud = optarg;
				break;
			case '?':
				if (optopt == 'b') {
					fprintf (stderr, "Option -b requires an argument [9600 or 115200].\n");
				} else if (isprint (optopt)) {
					fprintf (stderr, "Unknown option '-%c'\n", optopt);
				} else {
					fprintf (stderr, "Unknown option character '\\x%x'\n", optopt);
				}
				eflag = 1;
				break;
			default:
				exit (-1);
		}
	}

	// Handle unknown:
	for (index = optind; index < argc; index++) {
		fprintf (stderr, "Unknown argument %s\n", argv[index]);
		eflag = 1;
	}

	if (s_baud) {
		sscanf(s_baud, "%d", &baud);
		switch (baud)
		{
			case 9600:
				opts->baud = 9600;
				break;
			case 115200:
				opts->baud = 115200;
				break;
			default:
				fprintf (stderr, "Invalid baud %s, must be 9600 or 115200\n", s_baud);
				eflag = 1;
				break;
		}
	}
	if (hflag || eflag) {
		printf(USAGE_MSG);
		if (hflag)
			printf(DESC_USAGE_MSG);
		printf(OPTIONS_USAGE_MSG);
		exit(0);
	}
}

static void sig_handler(int _)
{
	(void)_;
	keep_running = 0;
}