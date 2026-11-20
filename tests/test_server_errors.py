"""A browser closing a tab drops its connections; the office's console stays quiet about it."""

from http.server import BaseHTTPRequestHandler

from office.server import OfficeServer, server_class

CLIENT = ("127.0.0.1", 50000)


def test_a_dropped_connection_prints_nothing(capsys):
    server = server_class("127.0.0.1")(("127.0.0.1", 0), BaseHTTPRequestHandler)
    try:
        for dropped in (
            ConnectionResetError(10054, "An existing connection was forcibly closed by the remote host"),
            ConnectionAbortedError(10053, "An established connection was aborted"),
            BrokenPipeError(32, "Broken pipe"),
        ):
            try:
                raise dropped
            except OSError:
                server.handle_error(None, CLIENT)
        assert capsys.readouterr().err == ""

        try:
            raise ValueError("a real bug")
        except ValueError:
            server.handle_error(None, CLIENT)
        assert "a real bug" in capsys.readouterr().err  # real errors still show
    finally:
        server.server_close()


def test_the_ipv6_server_is_quiet_too():
    assert issubclass(server_class("::1"), OfficeServer)
