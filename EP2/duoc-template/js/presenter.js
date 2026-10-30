/**
 * DUOC UC 2026 - HTML Slide Presentation Engine
 * Controls: Arrows, Space, Fullscreen (F), Overview (O/Esc), Print (P)
 */

class DuocPresenter {
  constructor() {
    this.canvas = document.getElementById('slide-canvas');
    this.slides = Array.from(document.querySelectorAll('.slide'));
    this.progressBar = document.getElementById('progress-bar');
    this.counter = document.getElementById('slide-counter');
    this.overviewOverlay = document.getElementById('overview-overlay');
    this.overviewGrid = document.querySelector('.overview-grid');
    
    this.currentIndex = 0;
    this.isOverview = false;

    this.init();
  }

  init() {
    if (this.slides.length === 0) return;

    // Handle initial hash (#3 -> slide 3)
    const hash = window.location.hash.replace('#', '');
    const initialIndex = parseInt(hash, 10) - 1;
    if (!isNaN(initialIndex) && initialIndex >= 0 && initialIndex < this.slides.length) {
      this.currentIndex = initialIndex;
    }

    // Responsive canvas auto-scale
    this.updateScale();
    window.addEventListener('resize', () => this.updateScale());

    // Setup overview grid
    this.setupOverview();

    // Event listeners
    this.setupEvents();

    // Show initial slide
    this.goToSlide(this.currentIndex);
  }

  updateScale() {
    if (!this.canvas) return;
    const windowWidth = window.innerWidth;
    const windowHeight = window.innerHeight;
    const scale = Math.min(windowWidth / 1920, windowHeight / 1080);
    this.canvas.style.transform = `scale(${scale})`;
  }

  goToSlide(index) {
    if (index < 0 || index >= this.slides.length) return;

    this.slides.forEach((s, i) => {
      s.classList.toggle('active', i === index);
    });

    this.currentIndex = index;
    window.location.hash = `#${index + 1}`;

    // Update progress bar & counter
    if (this.progressBar) {
      const pct = ((index + 1) / this.slides.length) * 100;
      this.progressBar.style.width = `${pct}%`;
    }
    if (this.counter) {
      this.counter.textContent = `${index + 1} / ${this.slides.length}`;
    }

    // Close overview if open
    if (this.isOverview) {
      this.toggleOverview(false);
    }
  }

  nextSlide() {
    if (this.currentIndex < this.slides.length - 1) {
      this.goToSlide(this.currentIndex + 1);
    }
  }

  prevSlide() {
    if (this.currentIndex > 0) {
      this.goToSlide(this.currentIndex - 1);
    }
  }

  toggleFullscreen() {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen().catch(err => console.log(err));
    } else {
      if (document.exitFullscreen) {
        document.exitFullscreen();
      }
    }
  }

  toggleOverview(forceState = null) {
    this.isOverview = forceState !== null ? forceState : !this.isOverview;
    if (this.overviewOverlay) {
      this.overviewOverlay.classList.toggle('active', this.isOverview);
      if (this.isOverview) {
        // highlight current thumbnail
        const thumbs = document.querySelectorAll('.overview-thumb');
        thumbs.forEach((t, i) => {
          t.classList.toggle('current', i === this.currentIndex);
        });
      }
    }
  }

  setupOverview() {
    if (!this.overviewGrid) return;
    this.overviewGrid.innerHTML = '';

    this.slides.forEach((slide, idx) => {
      const thumb = document.createElement('div');
      thumb.className = 'overview-thumb';

      // Extract title from slide
      const titleElem = slide.querySelector('.slide-title, .cover-title, .section-title');
      const title = titleElem ? titleElem.textContent.trim() : `Diapositiva ${idx + 1}`;

      thumb.innerHTML = `
        <div class="thumb-num">Slide ${idx + 1}</div>
        <div class="thumb-title">${title}</div>
      `;

      thumb.addEventListener('click', () => {
        this.goToSlide(idx);
      });

      this.overviewGrid.appendChild(thumb);
    });
  }

  setupEvents() {
    // Keyboard navigation
    window.addEventListener('keydown', (e) => {
      if (this.isOverview && e.key === 'Escape') {
        this.toggleOverview(false);
        return;
      }

      switch (e.key) {
        case 'ArrowRight':
        case 'ArrowDown':
        case ' ':
        case 'PageDown':
          e.preventDefault();
          this.nextSlide();
          break;
        case 'ArrowLeft':
        case 'ArrowUp':
        case 'PageUp':
        case 'Backspace':
          e.preventDefault();
          this.prevSlide();
          break;
        case 'Home':
          e.preventDefault();
          this.goToSlide(0);
          break;
        case 'End':
          e.preventDefault();
          this.goToSlide(this.slides.length - 1);
          break;
        case 'f':
        case 'F':
          e.preventDefault();
          this.toggleFullscreen();
          break;
        case 'o':
        case 'O':
        case 'Escape':
          e.preventDefault();
          this.toggleOverview();
          break;
        case 'p':
        case 'P':
          if (e.ctrlKey || e.metaKey) return; // let native print shortcut work
          break;
      }
    });

    // Touch swipe support
    let touchStartX = 0;
    let touchEndX = 0;

    window.addEventListener('touchstart', (e) => {
      touchStartX = e.changedTouches[0].screenX;
    }, { passive: true });

    window.addEventListener('touchend', (e) => {
      touchEndX = e.changedTouches[0].screenX;
      if (touchStartX - touchEndX > 60) {
        this.nextSlide(); // Swipe left -> next
      } else if (touchEndX - touchStartX > 60) {
        this.prevSlide(); // Swipe right -> prev
      }
    }, { passive: true });

    // Toolbar buttons
    const prevBtn = document.getElementById('btn-prev');
    const nextBtn = document.getElementById('btn-next');
    const fsBtn = document.getElementById('btn-fullscreen');
    const ovBtn = document.getElementById('btn-overview');
    const printBtn = document.getElementById('btn-print');
    const closeOvBtn = document.getElementById('btn-close-overview');

    if (prevBtn) prevBtn.addEventListener('click', () => this.prevSlide());
    if (nextBtn) nextBtn.addEventListener('click', () => this.nextSlide());
    if (fsBtn) fsBtn.addEventListener('click', () => this.toggleFullscreen());
    if (ovBtn) ovBtn.addEventListener('click', () => this.toggleOverview());
    if (printBtn) printBtn.addEventListener('click', () => window.print());
    if (closeOvBtn) closeOvBtn.addEventListener('click', () => this.toggleOverview(false));
  }
}

// Auto-instantiate when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  window.presenter = new DuocPresenter();
});
