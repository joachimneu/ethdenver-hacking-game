#!/usr/bin/env python3

from http import server

class MyHTTPRequestHandler(server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_my_headers()

        server.SimpleHTTPRequestHandler.end_headers(self)

    def send_my_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")

if __name__ == '__main__':
    server.test(HandlerClass=MyHTTPRequestHandler)
