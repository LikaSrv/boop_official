import React from 'react';
import './Banner.css';

const Banner = () => {
  return (
    <div className="banner-container">
      <nav className="nav-header">
        <div className="logo">
          <span className="logo-text">Pet</span>
          <span className="paw">🐾</span>
          <span className="logo-text">foster</span>
        </div>
        <div className="nav-links">
          <a href="#" className="active">Home</a>
          <a href="#">About</a>
          <a href="#">Services</a>
          <a href="#">Pets</a>
          <a href="#">Contact</a>
          <button className="contact-button">Contact us</button>
        </div>
      </nav>

      <div className="hero-section">
        <div className="hero-content">
          <h1 className="hero-title">
            Adopt love,
            <br />
            foster happiness.
          </h1>

          <div className="stats">
            <div className="stat-item">
              <div className="stat-circle">
                <span>5k+</span>
                <small>Pets</small>
              </div>
            </div>
            <div className="stat-item">
              <div className="stat-circle">
                <span>2k+</span>
                <small>Doctors</small>
              </div>
            </div>
          </div>

          <div className="reviews">
            <div className="review-score">
              <span className="star">⭐</span>
              <span className="score">4.8</span>
              <span className="total-reviews">(1.5k Reviews)</span>
            </div>
            <div className="reviewer-avatars">
              <div className="avatar-stack">
                {/* These would be actual images in production */}
                <div className="avatar"></div>
                <div className="avatar"></div>
                <div className="avatar"></div>
                <div className="avatar"></div>
                <span className="more-avatars">+3k</span>
              </div>
            </div>
          </div>

          <div className="description">
            <h3>WHAT WE DO?</h3>
            <p>With a focus on matching the right pet with the right family, PetFoster makes it easy to adopt love and foster happiness.</p>
            <button className="view-pets-button">View pets</button>
          </div>
        </div>

        <div className="hero-image">
          <img src="https://hgzbeyxwlmegxvrhxpws.supabase.co/storage/v1/object/public/general_images//banner.jpg" alt="Happy Corgi" className="main-pet-image" />
        </div>
      </div>
    </div>
  );
};

export default Banner;
