import React from "react";
import { Navbar, Nav } from "react-bootstrap";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faGithub, faLinkedin } from "@fortawesome/free-brands-svg-icons";
import {
  faInfoCircle,
  faCode,
  faFileAlt,
  faEnvelope,
} from "@fortawesome/free-solid-svg-icons";
import { Link } from "react-router-dom";

const Header = () => {
  return (
    <Navbar className="bg-black custom-navbar shadow-sm">
      <Navbar.Collapse id="navbarNav">
        <Nav className="text-center">
          <Nav.Link as={Link} to="/">
            <span>About</span>
            <FontAwesomeIcon
              icon={faInfoCircle}
              className="ml-2 text-light ho"
            />
          </Nav.Link>
          <Nav.Link as={Link} to="/projects">
            <span>Projects</span>
            <FontAwesomeIcon icon={faCode} className="ml-2 text-light ho" />
          </Nav.Link>
          <Nav.Link as={Link} to="/resume">
            <span>Resume</span>
            <FontAwesomeIcon icon={faFileAlt} className="ml-2 text-light ho" />
          </Nav.Link>
          <Nav.Link as={Link} to="/contact">
            <span>Contact</span>
            <FontAwesomeIcon icon={faEnvelope} className="ml-2 text-light ho" />
          </Nav.Link>
        </Nav>
        <Nav className="ms-auto">
          <Nav.Link href="https://github.com/yourusername" aria-label="Github">
            <FontAwesomeIcon
              icon={faGithub}
              size="lg"
              className="text-light ho"
            />
          </Nav.Link>
          <Nav.Link
            href="https://linkedin.com/in/yourusername"
            aria-label="Linkedin"
          >
            <FontAwesomeIcon
              icon={faLinkedin}
              size="lg"
              className="text-light ho"
            />
          </Nav.Link>
        </Nav>
      </Navbar.Collapse>
    </Navbar>
  );
};

export default Header;
